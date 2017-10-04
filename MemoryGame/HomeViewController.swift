//
//  HomeViewController.swift
//  MemoryGame
//
//  Created by Dipti Ganatra on 13/07/17.
//  Copyright © 2017 DND. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        UserDefaults.standard.set(segue.identifier, forKey: "level")
    }
}

