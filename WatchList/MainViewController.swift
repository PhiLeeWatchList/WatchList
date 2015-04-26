//
//  MainViewController.swift
//  WatchList
//
//  Created by Phil Starner on 4/22/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit


class MainViewController: UIViewController, INBeaconServiceDelegate {
    
    
    @IBOutlet weak var transmitLabel: UILabel!
    @IBOutlet weak var transmitSwitch: UISwitch!
    @IBOutlet weak var textField: UITextView!
    
    var notificationSent:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black;
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "UITransmitOnNotification:",
            name: GlobalConstants.TRANSMIT_ON,
            object: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        INBeaconService.singleton().addDelegate(self)
        INBeaconService.singleton().startDetecting()
        
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
            INBeaconService.singleton().startBroadcasting()
            
        } else {
            self.transmitLabel.text = "You're in the dark."
            INBeaconService.singleton().stopBroadcasting()
        }
    }
    
    
    func service(service: INBeaconService!, foundDeviceUUID uuid: String!, withRange range: INDetectorRange) {
        
        var textFieldString:String = "Your pack is not here. I has sad."
        var sendNotification:Bool = false
        
        println("found \(uuid) \(range)")
        let myRange = range.value
        switch myRange {
        case 0:
             println("unknown")  //it looks like this essentially means "no detection"
        case 1:
            println("far")
            textFieldString = "I found someone and they are within 60ft!"
            sendNotification = true
        case 2:
            println("near")
            textFieldString = "I found someone and they are within 5ft!"
            sendNotification = true
        case 3:
            println("immediate")
            textFieldString = "I found someone and they are within makeout distance!"
            sendNotification = true
        default:
            println("Something else")
        }
        
        self.textField.text = textFieldString
        
        
        
        if(sendNotification && !self.notificationSent) {
            self.notificationSent = false
            let notification: UILocalNotification = UILocalNotification();
            
            notification.alertBody = "You're friend is here!!!";
            /*
            If the application is in the foreground, it will get a callback to application:didReceiveLocalNotification:.
            If it's not, iOS will display the notification to the user.
            */
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
        
    }
    
    
    
    
    
}
