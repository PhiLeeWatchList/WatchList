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
import MessageUI

class BeaconConfigViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var guidText: UITextField!
    @IBOutlet weak var firstText: UITextField!
    @IBOutlet weak var lastText: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    var majorInt:UInt16 = 0
    var minorInt:UInt16 = 0
    var first:String = ""
    var last:String = ""
    var guid:String = "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
    
    
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
        
        self.firstText.layer.cornerRadius = 6.0
        self.firstText.layer.masksToBounds = true
        self.firstText.layer.borderColor = UIColor.init(red: 112.0/255.0, green: 146.0/255.0, blue: 255.0/255.0, alpha: 1).CGColor
        self.firstText.layer.borderWidth = 1.0
        
        self.lastText.layer.cornerRadius = 6.0
        self.lastText.layer.masksToBounds = true
        self.lastText.layer.borderColor = UIColor.init(red: 112.0/255.0, green: 146.0/255.0, blue: 255.0/255.0, alpha: 1).CGColor
        self.lastText.layer.borderWidth = 1.0
        
        self.doneButton.layer.cornerRadius = 6.0
        self.doneButton.layer.masksToBounds = true
        self.doneButton.layer.borderColor = UIColor.init(red: 112.0/255.0, green: 146.0/255.0, blue: 255.0/255.0, alpha: 1).CGColor
        self.doneButton.layer.borderWidth = 1.0
    }
    
    
    @IBAction func onNewButton(sender: AnyObject) {
        self.randomBeaconValues()
    }
    
    
    
    @IBAction func onDone(sender: AnyObject) {
        //if all fields are good, then segue out and put us into transmit mode.
        NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.TRANSMIT_ON, object: nil)
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    @IBAction func onShare(sender: AnyObject) {
        var picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setSubject("WatchList Friend ID")
        
        picker.setMessageBody("Your friend \(self.firstText.text) has sent you a WatchList friend code!  They must really like you! Click the linke below from your iPhone mail and then \(self.firstText.text) will be able to see you around corners!!!!  Insane I know!!! <br><br> <a src=\"watchlist://?udid=\(self.guid)&first=\(self.firstText.text)&last=\(self.lastText.text)\">\(self.firstText.text) \(self.lastText.text)</a> </b> <br> <br> <br>   full url: watchlist://?udid=\(self.guid)&first=\(self.firstText.text)&last=\(self.lastText.text)", isHTML: true)
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func randomBeaconValues() {
        
        self.guidText.text = NSUUID().UUIDString;
        self.guid = self.guidText.text
        
//        self.majorInt = UInt16(arc4random_uniform(65535))
//        self.minorInt = UInt16(arc4random_uniform(65535))
//        
//        println("major: \(self.majorInt), minor \(self.minorInt)")
//        self.firstText.text = String(self.majorInt)
//        self.lastText.text = String(self.minorInt)
    }
    
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
