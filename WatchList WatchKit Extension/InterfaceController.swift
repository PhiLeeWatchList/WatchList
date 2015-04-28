//
//  InterfaceController.swift
//  WatchList WatchKit Extension
//
//  Created by Phil Starner on 4/21/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var table: WKInterfaceTable!
    
    @IBOutlet weak var noOneHereLabel: WKInterfaceLabel!
    
    var users = [String]()
    var initials = ""
    var tableCreated = false
    
    func refreshTable() {
        if tableCreated == false {
            
            table.setNumberOfRows(users.count, withRowType: "tableRowController")
            
            for (index, user) in enumerate(users) {
                let row = table.rowControllerAtIndex(index) as! tableRowController
                row.tableRowLabel.setText(user)
                row.initials.setText(initials)
            }
            
            tableCreated = true
        }
    }
    
    override func handleActionWithIdentifier(identifier: String?, forRemoteNotification remoteNotification: [NSObject : AnyObject]) {
        if let notificationIdentifier = identifier {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            let stringDate = dateFormatter.stringFromDate(NSDate())
            
            var user = notificationIdentifier + " arrived at " + stringDate
            var fullName: String = "First Last"
            let fullNameArr = fullName.componentsSeparatedByString(" ")
            
            var firstName: String = fullNameArr[0]
            var lastName: String = fullNameArr[1]
            
            var firstInitial = first(firstName)
            var lastInitial = first(lastName)
            var initials : String = String(firstInitial!) + String(lastInitial!)
            
            if NSUserDefaults.standardUserDefaults().objectForKey("users") != nil {
                users = NSUserDefaults.standardUserDefaults().objectForKey("users") as! [String]
                
            }
            
            noOneHereLabel.setHidden(true)
            
            users.append(user)
            
            NSUserDefaults.standardUserDefaults().setObject(users, forKey: "users")
            
            refreshTable()
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if NSUserDefaults.standardUserDefaults().objectForKey("users") != nil {
            users = NSUserDefaults.standardUserDefaults().objectForKey("users") as! [String]
            noOneHereLabel.setHidden(true)
        } else {
            noOneHereLabel.setHidden(false)
        }
        
        refreshTable()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
