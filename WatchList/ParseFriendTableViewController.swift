//
//  TableViewController.swift
//  WatchList
//
//  Created by Lee Strasheim on 5/26/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import CoreLocation


class ParseFriendTableViewController: PFQueryTableViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black;
        
        
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.revealViewController().rearViewRevealWidth = 130
        
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey(GlobalConstants.THIS_DEVICE_TRANSMIT_UUID) != nil) {
            //self.testSetupButton.hidden = true
        }
        
        
        
        layoutForDevices()
        startLocationManager()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func layoutForDevices() {
        
        
    }
    
    // Initialise the PFQueryTable tableview
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Configure the PFQueryTableView
        self.parseClassName = "WolfPack"
        self.textKey = "username"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
    }
    
    // Define the query that will provide the data for the table view
    override func queryForTable() -> PFQuery{
        var query = PFQuery(className: "WolfPack")
        query.orderByAscending("username")
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CustomCell") as! ParseFriendCell!
        if cell == nil {
            cell = ParseFriendCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CustomCell")
        }
        
        // Extract values from the PFObject to display in the table cell
        if let nameEnglish = object?["username"] as? String {
            cell?.name?.text = nameEnglish
        }
        if let location = object?["location"] as? String {
            cell?.location?.text = location
        }
        
        
        var initialThumbnail = UIImage(named: "logo")
        cell.profileImage.image = initialThumbnail
        if let thumbnail = object?["profilepic"] as? PFFile {
            cell.profileImage.file = thumbnail
            cell.profileImage.loadInBackground({ (image, error) -> Void in
                println("image loaded")
            })
        }
        
        return cell
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
    
    
    //CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location:CLLocation = locations[locations.count-1] as! CLLocation
        
        var geoPoint = PFGeoPoint(location: location)
        
        var user = PFUser.currentUser()
        var username = user?.username
        var query = PFQuery(className:"WolfPack")
        query.whereKey("username", equalTo:username!)
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                println("Successfully retrieved \(objects!.count).")
                // Do something with the found objects
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        object["location"] = geoPoint
                        object.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if error == nil {
                                var query = PFQuery(className:"WolfPack")
                                query.whereKey("location", nearGeoPoint:geoPoint)
                                query.limit = 10
                                
                                println("user: \(user?.username)  email: \(user?.email)")
                                query.findObjectsInBackgroundWithBlock({ (places: [AnyObject]?, error: NSError?) -> Void in
                                    //self.updateMap(places!)
                                })
                                
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
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
            // ...
        }
    }
    
}
