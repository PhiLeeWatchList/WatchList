//
//  StartViewController.swift
//  WatchList
//
//  Created by Lee Strasheim on 6/9/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit
import MapKit
import Parse
import GeoManager

class StartViewController: UIViewController, MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var username = ""
    var userInfo = [String:PFFile]()
    let user = PFUser.currentUser()!
    var usersHereArray = [String]()
    var trackingArray = [String]()
    var friendsArray = [String]()
    var tableViewRefreshTimer = NSTimer()
    var name = ""
    var isInBackground = false
    
    let geoManager = GeoManager.sharedInstance
    
    var objects = [PFObject]()
    
    //New Background Task Stuff
    var backgroundUpdateTask: UIBackgroundTaskIdentifier!
    
//    deinit {
//        geoManager.removeObserver(self, forKeyPath: "location")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black;
        
        geoManager.addObserver(self, forKeyPath: "location", options: .New, context: nil)
        GeoManager.sharedInstance.start()
        
        var latitude:CLLocationDegrees = 34.159725
        
        var longitude:CLLocationDegrees = -118.331573
        
        var latDelta:CLLocationDegrees = 0.05
        
        var lonDelta:CLLocationDegrees = 0.05
        
        var span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta,lonDelta)
        
        var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        var region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        mapView.setRegion(region, animated: true)
        
        mapView.showsUserLocation = true
        
        
        PFUser.currentUser()?.fetchInBackgroundWithBlock({ (user, error) -> Void in
            if error == nil {
                let updatedUser = user as! PFUser
                self.trackingArray = updatedUser["tracking"] as! [String]
                self.friendsArray = updatedUser["friends"] as! [String]
                println("new tracking users are \(self.trackingArray)")
                self.queryForTable()
            }
        })
        
        self.usersHereArray = [""]
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableViewRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(30, target:self, selector: Selector("reloadViews"), userInfo: nil, repeats: true)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterBackground:",
            name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterBackground:",
            name: UIApplicationWillTerminateNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterForeground:",
            name: UIApplicationWillEnterForegroundNotification, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.tableViewRefreshTimer.invalidate()
        println("table timer stopped")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func observeValueForKeyPath(keyPath: String,
        ofObject object: AnyObject,
        change: [NSObject : AnyObject], context: UnsafeMutablePointer<()>) {
            
            if object === geoManager && keyPath == "location" {
                self.updateParseLocation()
            }
    }
    
    func queryForTable(){
        var query = PFQuery(className: "WolfPack")
        if let location = GeoManager.sharedInstance.location {
            let geoPoint = PFGeoPoint(location: location)
            query.whereKey("location", nearGeoPoint:geoPoint)
            query.whereKey("username", containedIn: user["tracking"]! as! [String] )
        }
        query.whereKey("username", notEqualTo: user.username!)
        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
            if error == nil {
                self.objects = []
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        self.objects.append(object)
                    }
                    self.updateMap(objects)
                }
            }
        }
    }
    
    func reloadViews() {
    
        self.updateMap(self.objects)
    }
 
    func updateMap(users:[PFObject]) {
        self.mapView.removeAnnotations(self.mapView.annotations)
        for user in users {
            var annotation = MKPointAnnotation()
            let mapuser = user["username"] as! String
            var point = user["location"] as! PFGeoPoint
            var lat = point.latitude
            var lon = point.longitude
            var userLocation = CLLocationCoordinate2DMake(lat, lon)
            annotation.coordinate = userLocation
            annotation.title = mapuser
            self.mapView.addAnnotation(annotation)
            let userpic = user["profilepic"] as! PFFile
            self.userInfo[mapuser] = userpic
            if mapuser == username {
                self.mapView.centerCoordinate = userLocation
            }
            self.tableView.reloadData()
        }
    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
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
            
            annotationView!.centerImage = UIImageView(frame: CGRectMake(0, 0, annotationView!.size, annotationView!.size))
            annotationView!.centerImage.layer.cornerRadius = annotationView!.centerImage.frame.size.width / 2
            annotationView!.centerImage.layer.masksToBounds = true
            println("Annotation title is \(annotation.title)")
            if annotation.title == self.username {
                annotationView!.centerImage.layer.borderColor = annotationView!.selectedColor.CGColor
            } else {
                annotationView!.centerImage.layer.borderColor =  annotationView!.borderColor.CGColor
            }
            annotationView!.centerImage.layer.borderWidth = 2
            
            var newUserView:UIView = UIView(frame: CGRectMake(0,0, annotationView!.size, annotationView!.size))
            newUserView.addSubview(annotationView!.centerImage)
            
            //add to the field view
            annotationView!.addSubview(newUserView)
            
            annotationView!.annotation = annotation
        }
        else {
            annotationView!.annotation = annotation
        }
        
        //we must use some image for pin
        annotationView!.image = UIImage(named: "blank_pin")
        
        let userPicture = userInfo[annotation.title!] as PFFile!
        userPicture.getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            if (error == nil) {
                let image = UIImage(data:data!)
                annotationView!.centerImage.image = image
            }
        }
        
        return annotationView
    }
    
    
    func updateParseLocation(){
        
        if let location = GeoManager.sharedInstance.location {
            
            var geoPoint = PFGeoPoint(location: location)
            
            var user = PFUser.currentUser()
            var username = user?.username
            var query = PFQuery(className:"WolfPack")
            query.whereKey("username", equalTo:username!)
            
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                            object["location"] = geoPoint
                            object.saveInBackgroundWithBlock({ (success, error) -> Void in
                                if success {
                                    if self.isInBackground {
                                        self.checkLocation()
                                    } else {
                                        self.queryForTable()
                                    }
                                }
                            })
                        }
                    }
                } else {
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
        }
    }
    
    func checkLocation() {
        var query = PFQuery(className: "WolfPack")
        if let location = GeoManager.sharedInstance.location {
            let geoPoint = PFGeoPoint(location: location)
            query.whereKey("location", nearGeoPoint:geoPoint)
            query.whereKey("username", containedIn: user["tracking"]! as! [String] )
        }
        query.whereKey("username", notEqualTo: user.username!)
        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
            if let objects = objects as? [PFObject] {
                for object in objects {
                    let name = object["username"] as! String
                    if let location = object["location"] as? PFGeoPoint {
                        if let currentLocation = GeoManager.sharedInstance.location {
                            let point = PFGeoPoint(location: currentLocation)
                            let distance = location.distanceInMilesTo(point)
                            var message = "Here!"
                            let formatter = NSNumberFormatter()
                            formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
                            formatter.locale = NSLocale(localeIdentifier: "en_US")
                            
                            if (distance < 0.01)  {
                                if !contains(self.usersHereArray,name) {
                                    self.notifyLocation(name)
                                    self.usersHereArray.append(name)
                                }
                            }
                        }
                    }
                }

            }
        }
    }
    
    
    func notifyLocation(name:String) {
        var localNotification: UILocalNotification = UILocalNotification()
        localNotification.alertAction = ""
        localNotification.alertBody = "\(name) is here!"
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 1)
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    
    
    //New Background Task Stuff
    func beginBackgroundUpdateTask() {
        self.backgroundUpdateTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
            self.endBackgroundUpdateTask()
        })
    }
    
    func endBackgroundUpdateTask() {
        UIApplication.sharedApplication().endBackgroundTask(self.backgroundUpdateTask)
        self.backgroundUpdateTask = UIBackgroundTaskInvalid
    }
    
    //MARK: - Notifications
    func didEnterBackground(notification:AnyObject) {
        println("start backgroundmode")
        self.isInBackground = true
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.beginBackgroundUpdateTask()
            
            // Do something with the result.
            var timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "updateParseLocation", userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
            NSRunLoop.currentRunLoop().run()
            
            // End the background task.
            self.endBackgroundUpdateTask()
        })
    }
    
    func didEnterForeground(notification:AnyObject) {
        self.isInBackground = false
        println("end backgroundmode")
    }
    

}



// MARK : TableViewDataSource & Delegate Methods

extension StartViewController: UITableViewDelegate, UITableViewDataSource {
 
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("user count is \(self.objects.count)")
        return self.objects.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        println("refreshing table")
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as! UserTableViewCell?
        if cell == nil {
            cell = UserTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        }
        
        println("cell is \(cell)")
        
        let object = objects[indexPath.row]
        
        cell?.cellView?.layer.borderColor = UIColor.grayColor().CGColor
        cell?.cellView?.layer.borderWidth = 2
        cell?.cellView?.layer.cornerRadius = 10
        
        cell?.profilepic?.layer.borderColor = UIColor.whiteColor().CGColor
        cell?.profilepic?.layer.borderWidth = 1
        cell?.profilepic?.layer.cornerRadius = 26
        cell?.profilepic?.layer.masksToBounds = true
        
        // Extract values from the PFObject to display in the table cell
        if let username = object["username"] as? String {
            name = username
            println("username is \(username)")
            cell?.name?.text = username
        }
        if let location = object["location"] as? PFGeoPoint {
            if let currentLocation = GeoManager.sharedInstance.location {
                println("current location is \(currentLocation)")
                let point = PFGeoPoint(location: currentLocation)
                let distance = location.distanceInMilesTo(point)
                var message = "Here!"
                let formatter = NSNumberFormatter()
                formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
                formatter.locale = NSLocale(localeIdentifier: "en_US")
                
                if (distance > 0.01 && distance < 0.05)  {
                    let feet = distance * 5280.0
                    formatter.maximumFractionDigits = 0
                    message = formatter.stringFromNumber(feet)! + " feet away"
                    cell?.cellView?.layer.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1).CGColor
                } else if distance > 0.05 {
                    formatter.maximumFractionDigits = 2
                    message = formatter.stringFromNumber(distance)! + " miles away"
                    cell?.cellView?.layer.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1).CGColor
                }
                
                if message == "Here!" {
                    cell?.cellView?.layer.backgroundColor = UIColor(red: 120/255.0, green: 120/255.0, blue: 120/255.0, alpha: 0.5).CGColor
                    
                }
                cell?.location?.text = message
                println("message is \(message)")
            }
        }
        
        
        var initialThumbnail = UIImage(named: "logo")
        cell?.profilepic?.image = initialThumbnail
        if let thumbnail = object["profilepic"] as? PFFile {
            println("profile image is \(thumbnail)")
            cell?.profilepic?.file = thumbnail
            cell?.profilepic?.loadInBackground({ (image, error) -> Void in
                println("image loaded")
            })
        }
        
        
        println("cell is now \(cell)")
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! UserTableViewCell
        self.username = cell.name.text!
        updateMap(self.objects)
    }
    
}
