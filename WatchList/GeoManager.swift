//
//  GeoManager.swift
//  WatchList
//
//  Created by Lee Strasheim on 6/3/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import Foundation
import CoreLocation

public class GeoManager : NSObject, CLLocationManagerDelegate {
    
    public var locationManager:CLLocationManager = CLLocationManager()
    
    public var location:CLLocation?
    
    var locationAuthorized = false
    
    public class var sharedInstance: GeoManager {
        struct SharedInstance {
            static let instance = GeoManager()
        }
        return SharedInstance.instance
    }

    override init() {
        super.init()
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    public func start() {
        
        self.locationManager.requestAlwaysAuthorization()
        if self.isLocatingAllowed() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.distanceFilter = 1.0
            self.locationManager.pausesLocationUpdatesAutomatically = false
            self.locationManager.startUpdatingLocation()
        }
    }
    
    public func stop() {
        self.locationManager.stopUpdatingLocation()
        self.locationManager.delegate = nil
    }
    
    func isLocatingAllowed() -> Bool {
        var allowed = true
        if CLLocationManager.locationServicesEnabled() == false {
            allowed = false
        }
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied {
            allowed = false
        }
        
        return allowed
    }
    
    //MARK: - CLLocationManagerDelegate
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //self.willChangeValueForKey("location")
        self.location = locations.last 
        //self.didChangeValueForKey("location")
        print("did update location: \(self.location)")
        //self.locationManager.stopUpdatingLocation()
        NSNotificationCenter.defaultCenter().postNotificationName("NewLocation", object: nil)
    }
    
    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error getting location")
    }
    
    public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (!self.locationAuthorized && status == .AuthorizedWhenInUse) {
            self.start()
        }
    }
}
