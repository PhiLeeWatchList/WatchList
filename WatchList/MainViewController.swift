//
//  MainViewController.swift
//  WatchList
//
//  Created by Phil Starner on 4/22/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit
import CoreData
import DataBridge
import Parse
import Bolts
import ParseUI

class MainViewController: UIViewController, INBeaconServiceDelegate {
    
    
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    @IBOutlet weak var transmitLabel: UILabel!
    @IBOutlet weak var transmitSwitch: UISwitch!
    //@IBOutlet weak var textField: UITextView!
    @IBOutlet weak var userFieldView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var testSetupButton: UIButton!
    
    @IBOutlet weak var popoverView: UIView!
    @IBOutlet weak var messagePickView: UIView!
    
    @IBOutlet weak var switchPhil: UISwitch!
    @IBOutlet weak var switchLee: UISwitch!
    @IBOutlet weak var switchLisa: UISwitch!
    @IBOutlet weak var switchJackie: UISwitch!
    @IBOutlet weak var switchChris: UISwitch!
    @IBOutlet weak var switchForrest: UISwitch!
    @IBOutlet weak var switchiPad: UISwitch!
    @IBOutlet weak var switchJanna: UISwitch!
    
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
        
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.revealViewController().rearViewRevealWidth = 130
        
        //check to see if user defaults has transmit id
        self.checkUserDefualtsForTransmitSetting()
        
        
        INBeaconService.singleton().addDelegate(self)
        INBeaconService.singleton().startDetecting()
        

        self.hidePopoverView()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey(GlobalConstants.THIS_DEVICE_TRANSMIT_UUID) != nil) {
            self.testSetupButton.hidden = true
        }

        
        
        layoutForDevices()
        
        self.updateFriends()
        
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
    
    func layoutForDevices() {
        self.messagePickView.layer.cornerRadius = 6.0
        self.messagePickView.layer.masksToBounds = true
        
    }
    
    
    @IBAction func onTestSetup(sender: AnyObject) {
        showMessagePickView()
        self.testSetupButton.hidden = true
    }
    
    func enableTransmitionButtonTurnOn(){
        self.transmitSwitch.enabled = true
        self.transmitSwitch.setOn(true, animated: true)
        self.transmitLabel.text = "On"
        INBeaconService.singleton().startBroadcasting()
    }
    
    @IBAction func onFakeUser(sender: AnyObject) {

        
        var context = CoreDataStack.sharedInstance.managedObjectContext!
        let request = NSFetchRequest(entityName: "User")
        let predicate = NSPredicate(format: "selected == true")
        request.predicate = predicate
        
        var uuid = ""
        if let users = context.executeFetchRequest(request, error: nil) as? [User] {
            for user in users {
                uuid = user.guid
            
        //      var uuid:String = "BB284D88-5317-4FB4-9621-C5A3A49E61"
                
                var arrayCount:Int = self.personAddedArray.count;
                var endString:String = ""
        //        if (arrayCount<10) {
        //            endString = "0\(arrayCount)"
        //        } else {
        //            endString = "\(arrayCount)"
        //        }
                
        //      uuid = "\(uuid)\(endString)"
                var name = user.username
                if(self.canAddUserToField(uuid)) {
                    self.addUserToView(name)
                    
                    //self.addUserToView("dude\(endString)")
                    personAddedArray.append(uuid)
                }
            }
        }
    }
    
    
    @IBAction func onSwitchChange(sender: AnyObject) {
        if self.transmitSwitch.on {
            self.transmitLabel.text = "On"
            INBeaconService.singleton().startBroadcasting()
            
        } else {
            self.transmitLabel.text = "Off"
            INBeaconService.singleton().stopBroadcasting()
        }
    }
    
    func updateFriends() {
        var context = CoreDataStack.sharedInstance.managedObjectContext!
        let request = NSFetchRequest(entityName: "User")
        let users = context.executeFetchRequest(request, error: nil) as! [User]
        for user in users {
            println("User id for \(user.username) is \(user.id)")
            if user.id == "" {
                self.updateUserFromParse(user.username)
            }
        }
    }
    
    func updateUserFromParse(username:String) {
        var query = PFUser.query()
        query!.whereKey("username", equalTo:username)
        query!.getFirstObjectInBackgroundWithBlock { (object:PFObject?, error:NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                println("Successfully retrieved user \(object).")
                var user = object as! PFUser
                self.getImageFromParse(user)

                
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
            
        }
        
    }

    func getImageFromParse(object: PFUser) {
        
        let thumbNail = object["profilepic"] as! PFFile
        
        //println(thumbNail)
        
        thumbNail.getDataInBackgroundWithBlock({
            (imageData: NSData?, error: NSError?) -> Void in
            if (error == nil) {
                self.updateCoreDataUser(object,image: imageData!)
                //println(imageData)
            } else {
                var username = object["username"] as! String
                println("Error getting image data for \(username).")
            }
            
        })

    }
    
    
    func updateCoreDataUser(user:PFUser, image:NSData) {
        let user = user
        var context = CoreDataStack.sharedInstance.managedObjectContext!
        let fetchRequest : NSFetchRequest = NSFetchRequest(entityName: "User")
        let predicate = NSPredicate(format: "username == %@",user.username!)
        fetchRequest.predicate = predicate
        
        var error : NSError? = nil
        var results = context.executeFetchRequest(fetchRequest, error: &error) as! [User]
        if error != nil {
            println("An error occurred loading the data")
        } else {
            println("user id is \(user.objectId).")
            let result = results[0]
            result.id = user.objectId!
            result.image = image
            var saveError : NSError? = nil
            if !context.save(&saveError) {
                println("Could not update record")
            }
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
            self.addUserToView(nameString)
            personAddedArray.append(uuid)
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
        var imageBorderColor:UIColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1)
        var imageBgColor:UIColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1)
        var nameColor:UIColor = UIColor(red: 112.0/255.0, green: 146.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        var newUserLabel:UILabel = UILabel(frame: CGRectMake(0, userBubbleSize, userBubbleSize, labelSize))
        newUserLabel.text = name
        newUserLabel.textAlignment = NSTextAlignment.Center
        newUserLabel.textColor = nameColor
        
        var newUserImageView:UIImageView = UIImageView(frame: CGRectMake(0, 0, userBubbleSize, userBubbleSize))
        newUserImageView.layer.cornerRadius = newUserImageView.frame.size.width / 2
        newUserImageView.layer.masksToBounds = true
        newUserImageView.layer.borderColor = imageBorderColor.CGColor
        newUserImageView.layer.backgroundColor = imageBgColor.CGColor
        newUserImageView.layer.borderWidth = userBubbleSize/18
        
        
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
        
        let xOffset:CGFloat = userBubbleSize * CGFloat(self.personAddedArray.count);
        println("count: \(xOffset)")
        
        let point:CGPoint = CGPointMake(userBubbleSize/2.0 + xOffset, userBubbleSize/2.0)
        
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
    
    //MARK: switch stuff
    @IBAction func onSwitchPhil(sender: AnyObject) {
        self.storeUUIDToUserDefaults("CB284D88-5317-4FB4-9621-C5A3A49E6150")
        self.storeNameToUserDefaults("Philip Starner")
        
        self.switchLee.setOn(false, animated: true)
        self.switchLisa.setOn(false, animated: true)
        self.switchiPad.setOn(false, animated: true)
        self.switchChris.setOn(false, animated: true)
        self.switchJackie.setOn(false, animated: true)
        self.switchForrest.setOn(false, animated: true)
        self.switchJanna.setOn(false, animated: true)
    }
    
    @IBAction func onSwitchLee(sender: AnyObject) {
        self.storeUUIDToUserDefaults("CB284D88-5317-4FB4-9621-C5A3A49E6151")
        self.storeNameToUserDefaults("Lee Strasheim")
        self.switchPhil.setOn(false, animated: true)
        self.switchLisa.setOn(false, animated: true)
        self.switchiPad.setOn(false, animated: true)
        self.switchChris.setOn(false, animated: true)
        self.switchJackie.setOn(false, animated: true)
        self.switchForrest.setOn(false, animated: true)
        self.switchJanna.setOn(false, animated: true)
    }
    
    @IBAction func onSwitchLisa(sender: AnyObject) {
        self.storeUUIDToUserDefaults("CB284D88-5317-4FB4-9621-C5A3A49E6152")
        self.storeNameToUserDefaults("Lisa Starner")
        self.switchPhil.setOn(false, animated: true)
        self.switchLee.setOn(false, animated: true)
        self.switchiPad.setOn(false, animated: true)
        self.switchChris.setOn(false, animated: true)
        self.switchJackie.setOn(false, animated: true)
        self.switchForrest.setOn(false, animated: true)
        self.switchJanna.setOn(false, animated: true)
    }
    
    @IBAction func onSwitchiPad(sender: AnyObject) {
        self.storeUUIDToUserDefaults("CB284D88-5317-4FB4-9621-C5A3A49E6153")
        self.storeNameToUserDefaults("Phil's iPad")
        self.switchPhil.setOn(false, animated: true)
        self.switchLee.setOn(false, animated: true)
        self.switchLisa.setOn(false, animated: true)
        self.switchChris.setOn(false, animated: true)
        self.switchJackie.setOn(false, animated: true)
        self.switchForrest.setOn(false, animated: true)
        self.switchJanna.setOn(false, animated: true)
    }
    
    @IBAction func onSwitchJackie(sender: AnyObject) {
        self.storeUUIDToUserDefaults("CB284D88-5317-4FB4-9621-C5A3A49E6154")
        self.storeNameToUserDefaults("Jackie Kelley")
        self.switchPhil.setOn(false, animated: true)
        self.switchLee.setOn(false, animated: true)
        self.switchLisa.setOn(false, animated: true)
        self.switchChris.setOn(false, animated: true)
        self.switchiPad.setOn(false, animated: true)
        self.switchForrest.setOn(false, animated: true)
        self.switchJanna.setOn(false, animated: true)
    }
    
    @IBAction func onSwitchChris(sender: AnyObject) {
        self.storeUUIDToUserDefaults("CB284D88-5317-4FB4-9621-C5A3A49E6155")
        self.storeNameToUserDefaults("Chris Kelley")
        self.switchPhil.setOn(false, animated: true)
        self.switchLee.setOn(false, animated: true)
        self.switchLisa.setOn(false, animated: true)
        self.switchJackie.setOn(false, animated: true)
        self.switchiPad.setOn(false, animated: true)
        self.switchForrest.setOn(false, animated: true)
        self.switchJanna.setOn(false, animated: true)
    }
    
    @IBAction func onSwitchForrest(sender: AnyObject) {
        self.storeUUIDToUserDefaults("CB284D88-5317-4FB4-9621-C5A3A49E6156")
        self.storeNameToUserDefaults("Forrest Stewart")
        self.switchPhil.setOn(false, animated: true)
        self.switchLee.setOn(false, animated: true)
        self.switchLisa.setOn(false, animated: true)
        self.switchJackie.setOn(false, animated: true)
        self.switchiPad.setOn(false, animated: true)
        self.switchChris.setOn(false, animated: true)
        self.switchJanna.setOn(false, animated: true)
    }
    
    @IBAction func onSwitchJanna(sender: AnyObject) {
        self.storeUUIDToUserDefaults("CB284D88-5317-4FB4-9621-C5A3A49E6157")
        self.storeNameToUserDefaults("Janna Stewart")
        self.switchPhil.setOn(false, animated: true)
        self.switchLee.setOn(false, animated: true)
        self.switchLisa.setOn(false, animated: true)
        self.switchJackie.setOn(false, animated: true)
        self.switchiPad.setOn(false, animated: true)
        self.switchChris.setOn(false, animated: true)
        self.switchForrest.setOn(false, animated: true)
    }
    
    @IBAction func onMessagePickDone(sender: AnyObject) {
        
        enableTransmitionButtonTurnOn()
        self.hidePopoverView()
    }
    
    
    func storeUUIDToUserDefaults(userString: String) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(userString, forKey: GlobalConstants.THIS_DEVICE_TRANSMIT_UUID)
        
        INBeaconService.singleton().changeIdentifier(userString)
    }
    
    func storeNameToUserDefaults(userString: String) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(userString, forKey: GlobalConstants.THIS_DEVICE_TRANSMIT_NAME)
    }
    
    
    //MARK: popover stuff
    
    func hidePopoverView() {
        self.popoverView.hidden = true
    }
    
    func showMessagePickView() {
        self.view.bringSubviewToFront(self.popoverView)
        self.popoverView.hidden = false
        self.messagePickView.hidden = false
    }
    
    
}
