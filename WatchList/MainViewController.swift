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
    //@IBOutlet weak var textField: UITextView!
    @IBOutlet weak var userFieldView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    var userBubbleSize:CGFloat = 90.0  //change this per device
    var labelSize:CGFloat = 20
    
    var animator: UIDynamicAnimator!
    var snapBehavior: UISnapBehavior!
    
    var peopleHereArray = [UIView]()
    var personAddedArray = [String]()
    
    var notificationSent:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black;
        
        self.animator = UIDynamicAnimator(referenceView:userFieldView)
        
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
        
        var textFieldString:String = ""
        var nameString:String = self.whoHaveYouFound(uuid.uppercaseString)
        var sendNotification:Bool = false
        
        
        println("found \(uuid) \(range)")
        let myRange = range.value
        switch myRange {
        case 0:
             println("unknown")  //it looks like this essentially means "no detection"
        case 1:
            println("far")
            textFieldString = "I found \(nameString) within 60ft!"
            sendNotification = true
        case 2:
            println("near")
            textFieldString = "I found \(nameString) within 5ft!"
            sendNotification = true
        case 3:
            println("immediate")
            textFieldString = "I found \(nameString) within 1ft!"
            sendNotification = true
        default:
            println("Something else")
        }
        
        self.messageLabel.text = textFieldString
        
        //send a notification if friend is detected.
        if(self.canAddUserToField(uuid)) {
            let defaults = NSUserDefaults.standardUserDefaults()
            //let nameString = defaults.stringForKey(GlobalConstants.THIS_DEVICE_TRANSMIT_NAME)
            
            self.notificationSent = true
            let notification: UILocalNotification = UILocalNotification()
            
            notification.alertBody = "\(nameString) is here!!!"
            notification.soundName = UILocalNotificationDefaultSoundName
            /*
            If the application is in the foreground, it will get a callback to application:didReceiveLocalNotification:.
            If it's not, iOS will display the notification to the user.
            */
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            personAddedArray.append(uuid)
            self.addUserToView(nameString)
        }
//        if(sendNotification && !self.notificationSent) {
//        }
        
    }
    
    func checkUserDefualtsForTransmitSetting() {
        //if user defaults has been set, then the transmit switch can be turned on/off
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let name = defaults.stringForKey(GlobalConstants.THIS_DEVICE_TRANSMIT_UUID)
        {
            self.transmitSwitch.enabled = true
        }
    }
    
    
    //TODO: remove temp until we get fully functional coredata user stuff.
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
    
    func addUserToView (name: String) {
        var objectColor:UIColor = UIColor(red: 112.0/255.0, green: 146.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        
        var newUserLabel:UILabel = UILabel(frame: CGRectMake(0, userBubbleSize, userBubbleSize, labelSize))
        newUserLabel.text = name
        newUserLabel.textAlignment = NSTextAlignment.Center
        newUserLabel.textColor = objectColor
        
        var newUserImageView:UIImageView = UIImageView(frame: CGRectMake(0, 0, userBubbleSize, userBubbleSize))
        newUserImageView.layer.cornerRadius = newUserImageView.frame.size.width / 2
        newUserImageView.layer.masksToBounds = true
        newUserImageView.layer.borderColor = objectColor.CGColor
        newUserImageView.layer.borderWidth = userBubbleSize/14
        
        
        var newUserView:UIView = UIView(frame: CGRectMake(self.userFieldView.frame.width, (self.userFieldView.frame.height + userBubbleSize), userBubbleSize, userBubbleSize+labelSize))
        newUserView.addSubview(newUserImageView)
        newUserView.addSubview(newUserLabel)
        newUserView.tag = self.peopleHereArray.count //do not tag until added
        //add to the field view
        userFieldView.addSubview(newUserView)
        //add to array
        peopleHereArray.append(newUserView)
        
        //pop this guy onscreen.
        
        self.snapTheNewUserOnScreen(newUserView)
    }
    
    func snapTheNewUserOnScreen(userView: UIView) {
        let point:CGPoint = CGPointMake(userBubbleSize/2.0, userBubbleSize/2.0)
        
        self.animator.removeBehavior(self.snapBehavior)
        
        self.snapBehavior = UISnapBehavior(item: userView, snapToPoint: point)
        self.animator?.addBehavior(snapBehavior)
        
    }
    
    func canAddUserToField(newIdentifier: String) -> Bool {
        var canAdd:Bool = true;
        for (var i=0; i<self.personAddedArray.count; i++) {
            if (newIdentifier == self.personAddedArray[i]) {
                canAdd = false
            }
        }
        
        return canAdd

    }
    
    
}
