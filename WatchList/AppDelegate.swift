//
//  AppDelegate.swift
//  WatchList
//
//  Created by Phil Starner on 3/17/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit
import CoreData
import DataBridge
import Parse


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        application.statusBarHidden = true
        
        Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("qLkZlcrFiYuxh2g1r7GPeqpSz7ZJdm3BWsWshw9r",
            clientKey: "exRqP3hYh1qh8RbGSzTclc7UHCx7JVsct7BGSnrw")
        
        // [Optional] Track statistics around application opens.
        // PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        
        if(UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:")))
        {
            //allow user to accept location when backgrounded
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
        }
        else
        {
            //do iOS 7
        }
        
        let navigationBarAppearace = UINavigationBar.appearance()
        
        navigationBarAppearace.tintColor = UIColor.whiteColor()
        navigationBarAppearace.barTintColor = UIColor.blackColor()
        
        let userArray = ["lee","phil","chris"]
        
        let user = PFUser.currentUser()
        
        var saveFriend = false
        
        
        
        if (user != nil) {
            let query = PFUser.query()
            query!.whereKey("username", equalTo: user!.username! )
            query!.getFirstObjectInBackgroundWithBlock({ (object:PFObject?, error:NSError?) -> Void in
                if let object = object {
                    var friendsArray = object["friends"] as! [String]
                    for friend in userArray {
                        if !friendsArray.contains(friend) && friend != user!.username! {
                            friendsArray.append(friend)
                            print("new friend \(friend) was added")
                            saveFriend = true
                        }
                    }
                    if saveFriend {
                        object["friends"] = friendsArray
                        object.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if success {
                                print("new friends updated")
                            }
                        })
                    }
                }
            })
        }
        
        
// Old CoreData code
//        var context = CoreDataStack.sharedInstance.managedObjectContext!
//        let request = NSFetchRequest(entityName: "User")
//        let savedUsers = context.executeFetchRequest(request, error: nil) as! [User]
//        var savedUsernames = [String]()
//        for username in savedUsers {
//            savedUsernames.append(username.username)
//        }

        
//        for user in userArray {
//            if contains(savedUsernames,user) {
//                println("User \(user) already exists")
//            } else {
//                var context = CoreDataStack.sharedInstance.managedObjectContext!
//                var person = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: context) as! User
//                person.username = user
//                person.guid = ""
//                person.id = ""
//                person.selected = false
//                context.save(nil)
//            }
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
        
        
        CoreDataStack.sharedInstance.saveContext()
        
    }

    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
            
            if let queryItems = components!.queryItems! as? [NSURLQueryItem]
            {
                let user = PFUser.currentUser()
                
                var saveFriend = false
                
                if (user != nil) {
                    var query = PFUser.query()
                    query!.whereKey("username", equalTo: user!.username! )
                    query!.getFirstObjectInBackgroundWithBlock({ (object:PFObject?, error:NSError?) -> Void in
                        if let object = object {
                            var friendsArray = object["friends"] as! [String]
                            let friend = queryItems[0].value!
                            if !friendsArray.contains(friend) && friend != user!.username! {
                                friendsArray.append(friend)
                                print("new friend \(friend) was added")
                                saveFriend = true
                            }
                            if saveFriend {
                                object["friends"] = friendsArray
                                object.saveInBackgroundWithBlock({ (success, error) -> Void in
                                    if success {
                                        print("new friends updated")
                                    }
                                })
                            }
                        }
                    })
                }
            }
        
        return true
        
    }

    //                var context = CoreDataStack.sharedInstance.managedObjectContext!
    //                let request = NSFetchRequest(entityName: "User")
    //                let savedUsers = context.executeFetchRequest(request, error: nil) as! [User]
    //                var savedUsernames = [String]()
    //                for username in savedUsers {
    //                    savedUsernames.append(username.username)
    //                }
    //
    //                for saved in savedUsernames {
    //                    if contains(savedUsernames, queryItems[0].value!) {
    //                        println("User \(queryItems[0].value!) already exists")
    //                    } else {
    //                        var context = CoreDataStack.sharedInstance.managedObjectContext!
    //                        var person = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: context) as! User
    //                        person.username = queryItems[0].value!
    //                        person.guid = queryItems[1].value!
    //                        person.id = ""
    //                        person.selected = false
    //                        context.save(nil)
    //                    }
    //                }

    
    
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




}

