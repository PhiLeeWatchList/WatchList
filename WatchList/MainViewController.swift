//
//  MainViewController.swift
//  WatchList
//
//  Created by Phil Starner on 4/22/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    
    @IBOutlet weak var transmitLabel: UILabel!
    @IBOutlet weak var transmitSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black;
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "UITransmitOnNotification:",
            name: GlobalConstants.TRANSMIT_ON,
            object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func UITransmitOnNotification(notification: NSNotification){
        println("got a transmit on notification")
        self.transmitSwitch.setOn(true, animated: true)
        self.transmitLabel.text = "Your pack can see you!"
    }
    
    @IBAction func onSwitchChange(sender: AnyObject) {
        if self.transmitSwitch.on {
            self.transmitLabel.text = "Your pack can see you!"
        } else {
            self.transmitLabel.text = "You're in the dark."
        }
    }
}
