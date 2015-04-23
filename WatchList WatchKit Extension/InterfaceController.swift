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
    
    var users = [String]()
    
    var tableCreated = false
    
    func refreshTable() {
        if tableCreated == false {
            
            table.setNumberOfRows(users.count, withRowType: "tableRowController")
            
            for (index, user) in enumerate(users) {
                let row = table.rowControllerAtIndex(index) as! tableRowController
                row.tableRowLabel.setText(user)
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
            
            
            if NSUserDefaults.standardUserDefaults().objectForKey("users") != nil {
                users = NSUserDefaults.standardUserDefaults().objectForKey("users") as! [String]
            }
            
            users.append(user)
            
            NSUserDefaults.standardUserDefaults().setObject(users, forKey: "users")
            
            refreshTable()
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if NSUserDefaults.standardUserDefaults().objectForKey("users") != nil {
            users = NSUserDefaults.standardUserDefaults().objectForKey("users") as! [String]
        } else {
            users.append("No one has arrived yet")
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
