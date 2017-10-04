//
//  GameViewController.swift
//  MemoryGame
//
//  Created by Dipti Ganatra on 13/07/17.
//  Copyright © 2017 DND. All rights reserved.
//

import UIKit

class GameViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var lblHighScore: UILabel!
    @IBOutlet var lblScore: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    var marrRandom : NSMutableArray = NSMutableArray()
    var marrRevealedImagesIndex : NSMutableArray = NSMutableArray()
    var numOfItemsInRow = 0
    var currentImageIndex = 0
    var prevImageName = ""
    var prevCell : CollectionViewCell = CollectionViewCell()
    var CurrCell : CollectionViewCell = CollectionViewCell()
    var startTime = NSDate.timeIntervalSinceReferenceDate
    var scoreTimer : Timer = Timer()
    
    //MARK: ----View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("view did load")
        collectionView.delegate = self
        collectionView.dataSource = self
        if UserDefaults.standard.value(forKey: "level") as! String == "easy" {
            numOfItemsInRow = 4
            lblHighScore.text = UserDefaults.standard.value(forKey: AppDelegate.constants.highScoreEasy) as? String
        } else if UserDefaults.standard.value(forKey: "level") as! String == "medium" {
            numOfItemsInRow = 6
            lblHighScore.text = UserDefaults.standard.value(forKey: AppDelegate.constants.highScoreEasy) as? String
        } else if UserDefaults.standard.value(forKey: "level") as! String == "hard" {
            numOfItemsInRow = 6//8
            lblHighScore.text = UserDefaults.standard.value(forKey: AppDelegate.constants.highScoreEasy) as? String
        }
        
        while marrRandom.count < ((numOfItemsInRow * numOfItemsInRow)) {
            let rnd1 = arc4random_uniform(UInt32((numOfItemsInRow * numOfItemsInRow) / 2))
            if !marrRandom.contains(rnd1) {
                marrRandom.add(rnd1)
                marrRandom.add(rnd1)
            }
        }
        print("high \(UserDefaults.standard.value(forKey: AppDelegate.constants.highScoreEasy))")
        shuffleArray()
        collectionView.reloadData()
        
        scoreTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: ----Collection View Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return marrRandom.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.imgView.image = UIImage(named:"\(marrRandom.object(at: currentImageIndex)).png")
        
        let num = marrRandom.object(at: currentImageIndex) as! UInt32
        cell.btn.tag = Int(num)
        cell.btn.layer.setValue(cell, forKey: "cell")
//        cell.btn.setTitle("\(num)", for: UIControlState.normal)
        
        if marrRevealedImagesIndex.contains("\(num)") {
            cell.btn.alpha = 0
        } else {
            cell.btn.alpha = 1
        }
        currentImageIndex += 1
        return cell
    }
    
    //Use for size
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size : CGSize = CGSize(width:Int(Float(collectionView.bounds.size.width) / Float(numOfItemsInRow)) , height:Int(Float(collectionView.bounds.size.height) / Float(numOfItemsInRow)))
        return size
    }
    
    //MARK: ----Action Methods
    @IBAction func btnBackTapped(_ sender: AnyObject) {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func cellBtnTapped(_ sender: AnyObject) {
        print("btn tap")
        let btn : UIButton = sender as! UIButton
        UIView.transition(with: btn, duration: 1.0, options: .transitionFlipFromRight, animations: {
            btn.alpha = 0
        }) { (true) in
        }
        
        if prevImageName == "" {
            print("prev nil")
            prevImageName = "\(btn.tag)"
            prevCell = btn.layer.value(forKey: "cell") as! CollectionViewCell
        } else {
            
            print("prev image :\(prevImageName)  curr image:\(btn.tag)")
            if(prevImageName == "\(btn.tag)") {
                print("prev not nil")
                marrRevealedImagesIndex.add("\(btn.tag)")
                if marrRevealedImagesIndex.count == marrRandom.count / 2 {
                    self.scoreTimer.invalidate()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "mm:ss"
                    let date = dateFormatter.date(from: lblScore.text!)
                    print("date \(lblScore.text!)")
                    
                    if UserDefaults.standard.value(forKey: "level") as! String == "easy" {
                        let highScore = UserDefaults.standard.value(forKey: AppDelegate.constants.highScoreEasy) as! String
                        let currScore = lblScore.text!
                        var arrHigh = highScore.components(separatedBy: ":")
                        var arrCurr = currScore.components(separatedBy: ":")
                        
                        if (Int(arrCurr[0])! < Int(arrHigh[0])!) {
                            print("high")
                            UserDefaults.standard.set(lblScore.text!, forKey: AppDelegate.constants.highScoreEasy)
                        } else if(Int(arrCurr[0])! == Int(arrHigh[0])!) {
                            if Int(arrCurr[1])! <= Int(arrHigh[1])! {
                                print("high")
                                UserDefaults.standard.set(lblScore.text!, forKey: AppDelegate.constants.highScoreEasy)
                            }
                        }
                    } else if UserDefaults.standard.value(forKey: "level") as! String == "medium" {
                        
                    } else if UserDefaults.standard.value(forKey: "level") as! String == "hard" {
                        
                    }
                    MTPopUp(frame: self.view.frame).show(complete: { (index) in
                        self.navigationController!.popViewController(animated: true)
                        }, view: self.view, animationType: MTAnimation.ZoomIn_ZoomOut, strMessage: "Great! You completed the level in \(lblScore.text!) minutes.", btnArray: ["Ok"], strTitle: "Memory Game")
                }
            } else {
                collectionView.isUserInteractionEnabled = false
                CurrCell = btn.layer.value(forKey: "cell") as! CollectionViewCell
                Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(self.reloadCollectionView), userInfo: nil, repeats: false)
                
            }
            prevImageName = ""
        }
        
    }
    
    //MARK: ----Other Methods
    
    func reloadCollectionView() {
        collectionView.isUserInteractionEnabled = true
        UIView.transition(with: prevCell.btn, duration: 1.0, options: .transitionFlipFromLeft, animations: {
            self.prevCell.btn.alpha = 1
        }) { (true) in
        }
        
        UIView.transition(with: CurrCell.btn, duration: 1.0, options: .transitionFlipFromLeft, animations: {
            self.CurrCell.btn.alpha = 1
        }) { (true) in
        }
    }
    
    func shuffleArray()  {
        for _ in 0...marrRandom.count - 1 {
            let rnd1 = arc4random_uniform(UInt32(marrRandom.count))
            let rnd2 = arc4random_uniform(UInt32(marrRandom.count))
            marrRandom.exchangeObject(at: Int(rnd1), withObjectAt: Int(rnd2))
        }
        print("shuffle\(marrRandom)")
    }
    
    func updateTime() {
        
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        
        //Find the difference between current time and start time.
        
        var elapsedTime: TimeInterval = currentTime - startTime
        
        //calculate the minutes in elapsed time.
        
        let minutes = UInt8(elapsedTime / 60)
        
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        
        let seconds = UInt8(elapsedTime)
        
        elapsedTime -= TimeInterval(seconds)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strMinutes = (minutes < 10) ? String(format: "%01d", minutes) : String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        
        lblScore.text = "\(strMinutes):\(strSeconds)"
        
        //            displayTimeLabel.text = “\(strMinutes):\(strSeconds):\(strFraction)”
        
    }
}
