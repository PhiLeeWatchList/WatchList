//
//  BeaconConfigViewController.swift
//  WatchList
//
//  Created by Phil Starner on 4/22/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class BeaconConfigViewController: UIViewController {
    
    
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var guidText: UITextField!
    @IBOutlet weak var majorText: UITextField!
    @IBOutlet weak var minorText: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    var majorInt:UInt16 = 0
    var minorInt:UInt16 = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.layoutForDevices()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func layoutForDevices() {
        
        
        self.newButton.layer.cornerRadius = 6.0
        self.newButton.layer.masksToBounds = true
        self.newButton.layer.borderColor = UIColor.init(red: 112.0/255.0, green: 146.0/255.0, blue: 255.0/255.0, alpha: 1).CGColor
        self.newButton.layer.borderWidth = 1.0
        
        
        self.majorText.layer.cornerRadius = 6.0
        self.majorText.layer.masksToBounds = true
        self.majorText.layer.borderColor = UIColor.init(red: 112.0/255.0, green: 146.0/255.0, blue: 255.0/255.0, alpha: 1).CGColor
        self.majorText.layer.borderWidth = 1.0
        
        self.minorText.layer.cornerRadius = 6.0
        self.minorText.layer.masksToBounds = true
        self.minorText.layer.borderColor = UIColor.init(red: 112.0/255.0, green: 146.0/255.0, blue: 255.0/255.0, alpha: 1).CGColor
        self.minorText.layer.borderWidth = 1.0
        
        
        self.doneButton.layer.cornerRadius = 6.0
        self.doneButton.layer.masksToBounds = true
        self.doneButton.layer.borderColor = UIColor.init(red: 112.0/255.0, green: 146.0/255.0, blue: 255.0/255.0, alpha: 1).CGColor
        self.doneButton.layer.borderWidth = 1.0
    }
    
    
    @IBAction func onNewButton(sender: AnyObject) {
        self.guidText.text = self.randomGUID()
    }
    
    @IBAction func onDone(sender: AnyObject) {
        //if all fields are good, then segue out and put us into transmit mode.
        NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.TRANSMIT_ON, object: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func onShare(sender: AnyObject) {
    }
    
    func randomGUID() -> String {
        return NSUUID().UUIDString;
    }
}
