//
//  TableViewController.swift
//  WatchList
//
//  Created by Lee Strasheim on 5/26/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit
import GeoManager



class ParseFriendTableViewController: PFQueryTableViewController {
    
    @IBOutlet weak var menuBarButton: UIBarButtonItem!

    let user = PFUser.currentUser()!
    
    var usersHereArray = [String]()
    var trackingArray = [String]()
    var friendsArray = [String]()
    var tableViewRefreshTimer = NSTimer()
    var name = ""
    var isInBackground = false
    
    let geoManager = GeoManager.sharedInstance
    
    //New Background Task Stuff
    var backgroundUpdateTask: UIBackgroundTaskIdentifier!
    
    deinit {
        geoManager.removeObserver(self, forKeyPath: "location")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black;

        
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.revealViewController().rearViewRevealWidth = 160
        
        geoManager.addObserver(self, forKeyPath: "location", options: .New, context: nil)
        GeoManager.sharedInstance.start()
        
        
        PFUser.currentUser()?.fetchInBackgroundWithBlock({ (user, error) -> Void in
            if error == nil {
                let updatedUser = user as! PFUser
                self.trackingArray = updatedUser["tracking"] as! [String]
                self.friendsArray = updatedUser["friends"] as! [String]
                print("new tracking users are \(self.trackingArray)")
                self.loadObjects()
            }
        })
        
        self.usersHereArray = [""]
        
    }
    
    func reloadTableView () {
        print("tableView updated")
        self.loadObjects()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableViewRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(30, target:self, selector: Selector("reloadTableView"), userInfo: nil, repeats: true)
        print("table timer started")
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
        print("table timer stopped")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func observeValueForKeyPath(keyPath: String?,
        ofObject object: AnyObject?,
        change: [String : AnyObject]?, context: UnsafeMutablePointer<()>) {
            
            if object === geoManager && keyPath == "location" {
                self.updateParseLocation()
            }
    }
    
    
    // Initialise the PFQueryTable tableview
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Configure the PFQueryTableView
        self.parseClassName = "WolfPack"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
    }
    
    // Define the query that will provide the data for the table view
    override func queryForTable() -> PFQuery{
        let query = PFQuery(className: "WolfPack")
        if let location = GeoManager.sharedInstance.location {
            let geoPoint = PFGeoPoint(location: location)
            query.whereKey("location", nearGeoPoint:geoPoint)
            query.whereKey("username", containedIn: user["tracking"]! as! [String] )
        }        
        query.whereKey("username", notEqualTo: user.username!)
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {
        
        print("refreshing table")
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CustomCell") as! ParseFriendCell!
        if cell == nil {
            cell = ParseFriendCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CustomCell")
        }
        
        cell?.cellView?.layer.borderColor = UIColor.grayColor().CGColor
        cell?.cellView?.layer.borderWidth = 2
        cell?.cellView?.layer.cornerRadius = 10
        
        // Extract values from the PFObject to display in the table cell
        if let username = object?["username"] as? String {
            name = username
            cell?.name?.text = username
        }
        if let location = object?["location"] as? PFGeoPoint {
            if let currentLocation = GeoManager.sharedInstance.location {
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
            }
        }
        
        
        let initialThumbnail = UIImage(named: "logo")
        cell.profileImage.image = initialThumbnail
        if let thumbnail = object?["profilepic"] as? PFFile {
            cell.profileImage.file = thumbnail
            cell.profileImage.loadInBackground({ (image, error) -> Void in
                print("image loaded")
            })
        }
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ParseFriendCell;
    
        name = cell.name!.text!
        
        performSegueWithIdentifier("toMapView", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toMapView" {
            tableViewRefreshTimer.invalidate()
            
            let vc = segue.destinationViewController as! MapViewController
            vc.username = name
        }
    }
    
    
    func updateParseLocation(){
        
        if let location = GeoManager.sharedInstance.location {
            
            var geoPoint = PFGeoPoint(location: location)
            
            var user = PFUser.currentUser()
            var username = user?.username
            var query = PFQuery(className:"WolfPack")
            query.whereKey("username", equalTo:username!)
            
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    for object in objects! {
                        object["location"] = geoPoint
                        object.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if success {
                                if self.isInBackground {
                                    self.checkLocation()
                                } else {
                                    self.loadObjects()
                                }
                            }
                        })
                    }
                } else {
                    // Log details of the failure
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        }
    }

    func checkLocation() {
        let query = PFQuery(className: "WolfPack")
        if let location = GeoManager.sharedInstance.location {
            let geoPoint = PFGeoPoint(location: location)
            query.whereKey("location", nearGeoPoint:geoPoint)
            query.whereKey("username", containedIn: user["tracking"]! as! [String] )
        }
        query.whereKey("username", notEqualTo: user.username!)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let foundObjects = objects {
                for object in foundObjects {
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
                                if !self.usersHereArray.contains(name) {
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
        let localNotification: UILocalNotification = UILocalNotification()
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
        print("start backgroundmode")
        self.isInBackground = true
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.beginBackgroundUpdateTask()

            // Do something with the result.
            let timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "updateParseLocation", userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
            NSRunLoop.currentRunLoop().run()
            
            // End the background task.
            self.endBackgroundUpdateTask()
        })
    }
    
    func didEnterForeground(notification:AnyObject) {
        self.isInBackground = false
        print("end backgroundmode")
    }
    
}
