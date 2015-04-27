//
//  AddFriendsViewController.swift
//  WatchList
//
//  Created by Phil Starner on 4/22/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit

class AddFriendsViewController: UIViewController, UITableViewDelegate {
    
    var users = [User]()
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black;
        
        if NSUserDefaults.standardUserDefaults().objectForKey("users") != nil {
            var arrayOfObjectsUnarchivedData = defaults.dataForKey("users")!
            users = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsUnarchivedData) as! [User]
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if NSUserDefaults.standardUserDefaults().objectForKey("users") != nil {
            var arrayOfObjectsUnarchivedData = defaults.dataForKey("users")!
            users = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsUnarchivedData) as! [User]
            
        }
        
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> TableViewCell {
        let cell = TableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        
        if NSUserDefaults.standardUserDefaults().objectForKey("users") != nil {
            var arrayOfObjectsUnarchivedData = defaults.dataForKey("users")!
            users = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsUnarchivedData) as! [User]
            
        } else {
            users = []
        }
        
        for (index, user) in enumerate(users) {
            cell.initials?.text = Array(arrayLiteral: user.first)[0] + Array(arrayLiteral: user.last)[0]
            cell.label?.text = user.first + " " + user.last
        }

        return cell
    }
}
