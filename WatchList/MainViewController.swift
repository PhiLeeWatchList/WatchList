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
        
        //check to see if user defaults has transmit id
        self.checkUserDefualtsForTransmitSetting()
        
        
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
        self.transmitSwitch.enabled = true
        self.transmitSwitch.setOn(true, animated: true)
        self.transmitLabel.text = "Your pack can see you!"
        INBeaconService.singleton().startBroadcasting()
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
        
        println("found device: \(uuid)")
        
        var textFieldString:String = "Your pack is not here. I has sad."
        var nameString:String = self.whoHaveYouFound(uuid.uppercaseString)
        var sendNotification:Bool = false
        
        
        println("found \(uuid) \(range)")
        let myRange = range.value
        switch myRange {
        case 0:
             println("unknown")  //it looks like this essentially means "no detection"
        case 1:
            println("far")
            textFieldString = "I found \(nameString) and they are within 60ft!"
            sendNotification = true
        case 2:
            println("near")
            textFieldString = "I found \(nameString) and they are within 5ft!"
            sendNotification = true
        case 3:
            println("immediate")
            textFieldString = "I found \(nameString) and they are within makeout distance!"
            sendNotification = true
        default:
            println("Something else")
        }
        
        self.textField.text = textFieldString
        
        
        //send a single notification if friend is detected.
        if(sendNotification && !self.notificationSent) {
            let defaults = NSUserDefaults.standardUserDefaults()
            let nameString = defaults.stringForKey(GlobalConstants.THIS_DEVICE_TRANSMIT_NAME)
            
            self.notificationSent = true
            let notification: UILocalNotification = UILocalNotification()
            
            notification.alertBody = "\(nameString) is here!!!"
            notification.soundName = UILocalNotificationDefaultSoundName
            /*
            If the application is in the foreground, it will get a callback to application:didReceiveLocalNotification:.
            If it's not, iOS will display the notification to the user.
            */
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
        
    }
    
    func checkUserDefualtsForTransmitSetting() {
        //if user defaults has been set, then the transmit switch can be turned on/off
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let name = defaults.stringForKey(GlobalConstants.THIS_DEVICE_TRANSMIT_UUID)
        {
            self.transmitSwitch.enabled = true
        }
    }
    
    func whoHaveYouFound(uuidString: String) -> String {
        if(uuidString == "CB284D88-5317-4FB4-9621-C5A3A49E6150") {
            return "Phil"
        } else if(uuidString == "CB284D88-5317-4FB4-9621-C5A3A49E6151") {
            return "Lee"
        } else if(uuidString == "CB284D88-5317-4FB4-9621-C5A3A49E6152") {
            return "Lisa"
        }else if(uuidString == "CB284D88-5317-4FB4-9621-C5A3A49E6153") {
            return "Phil's iPad"
        }else if(uuidString == "CB284D88-5317-4FB4-9621-C5A3A49E6154") {
            return "Jackie"
        }else if(uuidString == "CB284D88-5317-4FB4-9621-C5A3A49E6155") {
            return "Chris"
        }else if(uuidString == "CB284D88-5317-4FB4-9621-C5A3A49E6156") {
            return "Forrest"
        }else if(uuidString == "CB284D88-5317-4FB4-9621-C5A3A49E6157") {
            return "Janna"
        }
        
        return "someone"
    }
    
}
