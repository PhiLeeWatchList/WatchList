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
import CoreLocation
import MapKit

class MainViewController: UIViewController, INBeaconServiceDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
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
    
    var locationManager: CLLocationManager?
    
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
        
        // 34.153725, -118.336573 Morton's, Burbank CA

        let latitude:CLLocationDegrees = 34.159725
        
        let longitude:CLLocationDegrees = -118.331573
        
        let latDelta:CLLocationDegrees = 0.01
        
        let lonDelta:CLLocationDegrees = 0.01
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta,lonDelta)
        
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        mapView.setRegion(region, animated: true)
        
        self.startLocationManager()
        
        layoutForDevices()
        
        self.updateFriends()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func layoutForDevices() {
        self.messagePickView.layer.cornerRadius = 6.0
        self.messagePickView.layer.masksToBounds = true
        
    }
    
    func startLocationManager() {
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        
        //allow user to accept location
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager!.requestAlwaysAuthorization()
            locationManager!.requestWhenInUseAuthorization()
        }
        
        self.locationManager!.desiredAccuracy = kCLLocationAccuracyNearestTenMeters//kCLLocationAccuracyBest
        self.locationManager!.distanceFilter = 1.0
        
    }
    
    
    @IBAction func onTestSetup(sender: AnyObject) {
        showMessagePickView()
        self.testSetupButton.hidden = true
    }
    
    func enableTransmitionButtonTurnOn(){
        self.transmitSwitch.enabled = true
        self.transmitSwitch.setOn(true, animated: true)
        self.transmitLabel.text = "On"
        
        if (self.locationManager != nil) {
            
            if CLLocationManager.locationServicesEnabled() {
                print("starting up location updates")
                locationManager!.startUpdatingLocation()
            } else {
                print("NOT starting up location updates")
            }
        }
    }
    
    @IBAction func onFakeUser(sender: AnyObject) {
        
        let context = CoreDataStack.sharedInstance.managedObjectContext!
        let request = NSFetchRequest(entityName: "User")
        let predicate = NSPredicate(format: "selected == true")
        request.predicate = predicate
        
        if let users = (try? context.executeFetchRequest(request)) as? [User] {
            for user in users {
                print("show user \(user.username), guid is \(user.guid)")
                let uuid = user.guid
                let name = user.username
                let imageData = user.image
                if(self.canAddUserToField(uuid)) {
                    print("Can add user \(name)")
                    self.addUserToView(name,imageData: imageData)
                    self.personAddedArray.append(uuid)
                } else {
                    print("Can't add user \(name)")
                }
            }
        }
        
        let delay = 4.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.sendTestAlert()
        }
    }
    
    
    @IBAction func onSwitchChange(sender: AnyObject) {
        if self.transmitSwitch.on {
            self.transmitLabel.text = "On"
            INBeaconService.singleton().startBroadcasting()
            
            if (self.locationManager != nil) {
                
                if CLLocationManager.locationServicesEnabled() {
                    print("starting up location updates")
                    locationManager!.startUpdatingLocation()
                } else {
                    print("NOT starting up location updates")
                }
            }
            
        } else {
            self.transmitLabel.text = "Off"
            INBeaconService.singleton().stopBroadcasting()
            locationManager!.stopUpdatingLocation()
        }
    }
    
    func updateFriends() {
        let context = CoreDataStack.sharedInstance.managedObjectContext!
        let request = NSFetchRequest(entityName: "User")
        let users = (try! context.executeFetchRequest(request)) as! [User]
        for user in users {
            print("User id for \(user.username) is \(user.id)")
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
                print("Successfully retrieved user \(object).")
                var user = object as! PFUser
                self.getImageFromParse(user)

                
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
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
                let username = object["username"] as! String
                print("Error getting image data for \(username).")
            }
            
        })

    }
    
    
    func updateCoreDataUser(user:PFUser, image:NSData) {
        let user = user
        let context = CoreDataStack.sharedInstance.managedObjectContext!
        let fetchRequest : NSFetchRequest = NSFetchRequest(entityName: "User")
        let predicate = NSPredicate(format: "username == %@",user.username!)
        fetchRequest.predicate = predicate
        
        let error : NSError? = nil
        var results = (try! context.executeFetchRequest(fetchRequest)) as! [User]
        if error != nil {
            print("An error occurred loading the data")
        } else {
            let guid = user["guid"] as! String
            print("user guid is \(guid).")
            let result = results[0]
            result.id = user.objectId!
            result.image = image
            result.guid = guid
            var saveError : NSError? = nil
            do {
                try context.save()
            } catch let error as NSError {
                saveError = error
                print("Could not update record")
            }
            self.storeUUIDToUserDefaults(guid)
            self.storeNameToUserDefaults(user.username!)
        }

    }

    func updateMap(places: [AnyObject]) {
        mapView.removeAnnotations(self.mapView.annotations)
        for place in places {
            let annotation = MKPointAnnotation()
            let point = place["location"] as! PFGeoPoint
            let lat = point.latitude
            let lon = point.longitude
            let userLocation = CLLocationCoordinate2DMake(lat, lon)
            annotation.coordinate = userLocation
            annotation.title = place["username"] as! String
            
            mapView.addAnnotation(annotation)
        }
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView! {
        
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        let reuseId = "pin"
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? WLAnnotationView
        if annotationView == nil {
            annotationView = WLAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annotationView!.canShowCallout = true
            annotationView!.enabled = true

            
            annotationView!.size = 40.0
            annotationView!.centerLabel = UILabel(frame: CGRectMake(0, 0, annotationView!.size, annotationView!.size))
            
            annotationView!.centerLabel.layer.cornerRadius = annotationView!.centerLabel.frame.size.width / 2
            annotationView!.centerLabel.layer.masksToBounds = true
            annotationView!.centerLabel.layer.borderColor = annotationView!.borderColor.CGColor
            annotationView!.centerLabel.layer.borderWidth = annotationView!.size/8
            
            annotationView!.centerLabel.textAlignment = NSTextAlignment.Center
            annotationView!.centerLabel.textColor = .whiteColor()
            annotationView!.centerLabel.backgroundColor = annotationView!.bgColor
            
            annotationView!.centerImage = UIImageView(frame: CGRectMake(0, 0, annotationView!.size, annotationView!.size))
            annotationView!.centerImage.layer.cornerRadius = annotationView!.centerImage.frame.size.width / 2
            annotationView!.centerImage.layer.masksToBounds = true
            annotationView!.centerImage.layer.borderColor =  annotationView!.borderColor.CGColor
            annotationView!.centerImage.layer.borderWidth = annotationView!.size/8
            
            var newUserView:UIView = UIView(frame: CGRectMake(0,0, annotationView!.size, annotationView!.size))
            newUserView.addSubview(annotationView!.centerImage)
            
            //add a label if we don't have user or a user.image returned
            if let user:User = self.getUser(annotation.title!!) {
                if (user.image == nil) {
                    newUserView.addSubview(annotationView!.centerLabel)
                }
            } else {
                newUserView.addSubview(annotationView!.centerLabel)
            }
            
            //add to the field view
            annotationView!.addSubview(newUserView)
            
            annotationView!.annotation = annotation
        }
        else {
            annotationView!.annotation = annotation
        }
        
        //we must use some image to allow callout
        annotationView!.image = UIImage(named: "blank_pin")
        
        //because we are deque reusing, we need to always set the image and label.
        if(annotation.title! != nil) {
            if let user:User = self.getUser(annotation.title!!) {
                if let imageData:NSData = user.image {
                    annotationView!.centerImage.image = UIImage(data: imageData)
                }
            }
        }
        if let txt = annotation.title {
            let labelString:String = annotation.title!!
            annotationView!.centerLabel.text  = labelString.substringWithRange(Range<String.Index>(start: labelString.startIndex, end: labelString.startIndex.advancedBy(1))).uppercaseString
        }
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        view.canShowCallout = true
    }
    
    func service(service: INBeaconService!, foundDeviceUUID uuid: String!, withRange range: INDetectorRange) {
//        var textFieldString:String = ""
//        var nameString:String = self.whoHaveYouFound(uuid.uppercaseString)
//        var sendNotification:Bool = false
//        
//        
//        println("found \(uuid) \(range)")
//        let myRange = range.value
//        switch myRange {
//        case 0:
//             println("unknown")  //it looks like this essentially means "no detection"
//        case 1:
//            println("far")
//            textFieldString = "I found \(nameString) within 60ft!"
//            sendNotification = true
//        case 2:
//            println("near")
//            textFieldString = "I found \(nameString) within 5ft!"
//            sendNotification = true
//        case 3:
//            println("immediate")
//            textFieldString = "I found \(nameString) within 1ft!"
//            sendNotification = true
//        default:
//            println("Something else")
//        }
//        
//        self.messageLabel.text = textFieldString
//        
//        //send a notification if friend is detected.
//        if(self.canAddUserToField(uuid)) {
//            var context = CoreDataStack.sharedInstance.managedObjectContext!
//            let request = NSFetchRequest(entityName: "User")
//            let predicate = NSPredicate(format: "selected == true")
//            request.predicate = predicate
//            
//            if let users = context.executeFetchRequest(request, error: nil) as? [User] {
//                for user in users {
//                    nameString = user.username
//                    var imageData = user.image
//                    self.notificationSent = true
//                    let notification: UILocalNotification = UILocalNotification()
//                    
//                    notification.alertBody = "\(nameString) is here!!!"
//                    notification.soundName = UILocalNotificationDefaultSoundName
//                    /*
//                    If the application is in the foreground, it will get a callback to application:didReceiveLocalNotification:.
//                    If it's not, iOS will display the notification to the user.
//                    */
//                    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
//                    self.addUserToView(nameString, imageData:imageData)
//                    personAddedArray.append(uuid)
//                    
//                }
//            }
//            
////            let defaults = NSUserDefaults.standardUserDefaults()
////            //let nameString = defaults.stringForKey(GlobalConstants.THIS_DEVICE_TRANSMIT_NAME)
////            
////            self.notificationSent = true
////            let notification: UILocalNotification = UILocalNotification()
////            
////            notification.alertBody = "\(nameString) is here!!!"
////            notification.soundName = UILocalNotificationDefaultSoundName
////            /*
////            If the application is in the foreground, it will get a callback to application:didReceiveLocalNotification:.
////            If it's not, iOS will display the notification to the user.
////            */
////            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
////            self.addUserToView(nameString)
////            personAddedArray.append(uuid)
//        }
////        if(sendNotification && !self.notificationSent) {
////        }
        
    }
    
    func checkUserDefualtsForTransmitSetting() {
        //if user defaults has been set, then the transmit switch can be turned on/off
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let name = defaults.stringForKey(GlobalConstants.THIS_DEVICE_TRANSMIT_UUID)
        {
            self.transmitSwitch.enabled = true
        }
    }
    
    func sendTestAlert() {
        let notification: UILocalNotification = UILocalNotification()
        
        notification.alertBody = "Test Alert!!!"
        notification.soundName = UILocalNotificationDefaultSoundName
        /*
        If the application is in the foreground, it will get a callback to application:didReceiveLocalNotification:.
        If it's not, iOS will display the notification to the user.
        */
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
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
    
    func addUserToView (name: String, imageData:NSData) {
        let imageBorderColor:UIColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1)
        let imageBgColor:UIColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1)
        let nameColor:UIColor = UIColor(red: 112.0/255.0, green: 146.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        let newUserLabel:UILabel = UILabel(frame: CGRectMake(0, userBubbleSize, userBubbleSize, labelSize))
        newUserLabel.text = name
        newUserLabel.textAlignment = NSTextAlignment.Center
        newUserLabel.textColor = nameColor
        
        let newUserImageView:UIImageView = UIImageView(frame: CGRectMake(0, 0, userBubbleSize, userBubbleSize))
        newUserImageView.layer.cornerRadius = newUserImageView.frame.size.width / 2
        newUserImageView.layer.masksToBounds = true
        newUserImageView.layer.borderColor = imageBorderColor.CGColor
        newUserImageView.layer.backgroundColor = imageBgColor.CGColor
        newUserImageView.layer.borderWidth = userBubbleSize/18
        newUserImageView.image = UIImage(data: imageData)
        
        let newUserView:UIView = UIView(frame: CGRectMake(0,0, userBubbleSize, userBubbleSize+labelSize))
        newUserView.addSubview(newUserImageView)
        newUserView.addSubview(newUserLabel)
        newUserView.tag = self.peopleHereArray.count //do not tag until added
        //add to the field view
        self.userFieldView.addSubview(newUserView)
        //add to array
        self.peopleHereArray.append(newUserView)
        
        //pop this guy onscreen.
        
        self.snapTheNewUserOnScreen(newUserView)
    }
    
    func snapTheNewUserOnScreen(userView: UIView) {
        
        let xOffset:CGFloat = userBubbleSize * CGFloat(self.userFieldView.subviews.count-1);
        print("count: \(self.userFieldView.subviews.count-1)")
        
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
    
    //MARK: corelocation queries
    
    func getUserImageData(username: String) -> NSData? {
        
        let context = CoreDataStack.sharedInstance.managedObjectContext!
        let request = NSFetchRequest(entityName: "User")
        
        if let users = (try? context.executeFetchRequest(request)) as? [User] {
            for user in users {
                if (user.username == username) {
                    return user.image
                }
            }
        }
        
        return nil
    }
    
    func getUser(username: String) -> User? {
        let context = CoreDataStack.sharedInstance.managedObjectContext!
        let request = NSFetchRequest(entityName: "User")
        
        if let users = (try? context.executeFetchRequest(request)) as? [User] {
            for user in users {
                if (user.username == username) {
                    return user
                }
            }
        }
        
        return nil
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
    
    //CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var location:CLLocation = locations[locations.count-1] 
        
        var geoPoint = PFGeoPoint(location: location)
    
        var user = PFUser.currentUser()
        var username = user?.username
        var query = PFQuery(className:"WolfPack")
        query.whereKey("username", equalTo:username!)
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count).")
                // Do something with the found objects
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        object["location"] = geoPoint
                        object.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if error == nil {
                                var query = PFQuery(className:"WolfPack")
                                query.whereKey("location", nearGeoPoint:geoPoint)
                                query.limit = 10
                                
                                print("user: \(user?.username)  email: \(user?.email)")
                                query.findObjectsInBackgroundWithBlock({ (places: [AnyObject]?, error: NSError?) -> Void in
                                    self.updateMap(places!)
                                })
                                
                            }
                        })
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        
        //        txtLatitude.text = "\(location.coordinate.latitude)";
        //        txtLongitude.text = "\(location.coordinate.longitude)";
        
        //attempt to start up beacon detection and broadcast
////        INBeaconService.singleton().removeDelegate(self)
//        INBeaconService.singleton().stopBroadcasting()
//        INBeaconService.singleton().stopDetecting()
//        
////        INBeaconService.singleton().addDelegate(self)
//        INBeaconService.singleton().startDetecting()
////
//        INBeaconService.singleton().startBroadcasting()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
        //        txtLatitude.text = "Can't get your location!"
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
            // ...
        }
    }
    
    
}
