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
            query.whereKey("username", equalTo: username)
            query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                if let object = objects?.last as? PFObject {
                    self.userObject = object
                    self.updateMap(object)
                }
        }
    }
    
    func updateMap(user:PFObject) {

        var annotation = MKPointAnnotation()
        var point = user["location"] as! PFGeoPoint
        var lat = point.latitude
        var lon = point.longitude
        var userLocation = CLLocationCoordinate2DMake(lat, lon)
        annotation.coordinate = userLocation
        annotation.title = user["username"] as! String
        mapView.centerCoordinate = userLocation
        mapView.addAnnotation(annotation)
        println("map location updated")

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
        
        //we must use some image to allow callout
        annotationView!.image = UIImage(named: "blank_pin")

        let userPicture = userObject["profilepic"] as! PFFile
        userPicture.getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            if (error == nil) {
                let image = UIImage(data:data!)
                annotationView!.centerImage.image = image
            }
        }
        
        return annotationView
    }
    
    
}
