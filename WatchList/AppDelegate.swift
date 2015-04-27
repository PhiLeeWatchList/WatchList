//
//  AppDelegate.swift
//  WatchList
//
//  Created by Phil Starner on 3/17/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit
import Foundation

//import CoreLocation //TODO: remove ibeacon

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate { //CLLocationManagerDelegate { //TODO: remove ibeacon
    
    let guid = ""
    let firstName = ""
    let lastName = ""
    
    var window: UIWindow?
    // var locationManager: CLLocationManager? //TODO: remove ibeacon


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        application.statusBarHidden = true
        
        //TODO: remove ibeacon
//        self.locationManager = CLLocationManager()
//        self.locationManager!.delegate = self
//        
//        //allow user to accept location
//        self.locationManager!.requestAlwaysAuthorization()
//        
//        if(UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:")))
//        {
//            //allow user to accept location when backgrounded
//            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil))
//        }
//        else
//        {
//            //do iOS 7
//        }
        
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool
    {
        
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
            
            if let queryItems = components?.queryItems as? [NSURLQueryItem]
            {
                
                var newUser = User(guid: queryItems[0].value!,first: queryItems[1].value!,last: queryItems[2].value!)
                
//                for (idx: Int, component: NSURLQueryItem) in enumerate(queryItems)
//                {
//                    println(component.value!)
//                    
//                    switch (idx) {
//                        case 0 :self.guid = component.value!
//                        case 1: self.firstName = component.value!
//                        case 2: self.lastName = component.value!
//                        default : println("default")
//                    }
//                    
//                    
//                }
                
                var users = [User]()
                
                let defaults = NSUserDefaults.standardUserDefaults()
                
                if NSUserDefaults.standardUserDefaults().objectForKey("users") != nil {
                    var arrayOfObjectsUnarchivedData = defaults.dataForKey("users")!
                    var users = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsUnarchivedData) as! [User]
                }
                
                users.append(newUser)
                
                var arrayOfObjectsData = NSKeyedArchiver.archivedDataWithRootObject(users)
                
                defaults.setObject(arrayOfObjectsData, forKey: "users")
                
                
            }
        
        return true
        
    }
    
    //TODO: remove ibeacon
//    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
//        /*
//        A user can transition in or out of a region while the application is not running. When this happens CoreLocation will launch the application momentarily, call this delegate method and we will let the user know via a local notification.
//        */
//        let notification: UILocalNotification = UILocalNotification();
//        
//        if(state == CLRegionState.Inside)
//        {
//            notification.alertBody = "You're inside the region";
//        }
//        else if(state == CLRegionState.Outside)
//        {
//            notification.alertBody = "You're outside the region";
//        }
//        else
//        {
//            return;
//        }
//        
//        /*
//        If the application is in the foreground, it will get a callback to application:didReceiveLocalNotification:.
//        If it's not, iOS will display the notification to the user.
//        */
//        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
//    }
//    
//    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
//        
//        // If the application is in the foreground, we will notify the user of the region's state via an alert.
//        
//        let alertController = UIAlertController(title: "Detection!", message:
//            notification.alertBody, preferredStyle: UIAlertControllerStyle.Alert)
//        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
//        
//        
//        self.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
//        
//    }


}

