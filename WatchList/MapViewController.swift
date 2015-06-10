//
//  MapViewController.swift
//  WatchList
//
//  Created by Lee Strasheim on 6/4/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit
import MapKit
import Parse


class MapViewController: UIViewController, MKMapViewDelegate {

    
    @IBOutlet var mapView: MKMapView!
    
    var username = String()
    var mapViewRefreshTimer = NSTimer()
    var userInfo = [String:PFFile]()
    var currentUser = PFUser.currentUser()?.username!
    
    var userObject = PFObject(className: "WolfPack")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = username
        
        var latitude:CLLocationDegrees = 34.159725
        
        var longitude:CLLocationDegrees = -118.331573
        
        var latDelta:CLLocationDegrees = 0.05
        
        var lonDelta:CLLocationDegrees = 0.05
        
        var span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta,lonDelta)
        
        var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        var region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        mapView.setRegion(region, animated: true)
        
        mapView.showsUserLocation = true
        
        self.queryParseUserLocation()
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.mapViewRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(30, target:self, selector: Selector("queryParseUserLocation"), userInfo: nil, repeats: true)
         println("map timer started")
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.mapViewRefreshTimer.invalidate()
        println("map timer stopped")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func queryParseUserLocation(){
            var query = PFQuery(className: "WolfPack")
            query.whereKey("username", notEqualTo: currentUser!)
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error:NSError?) -> Void in
            if objects != nil {
                println("found \(objects!.count)")
                self.updateMap(objects!)
            }
        }
            
    }
    
    func updateMap(users:[AnyObject]) {        
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
    
    
}
