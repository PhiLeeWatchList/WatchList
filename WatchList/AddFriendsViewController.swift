//
//  AddFriendsViewController.swift
//  WatchList
//
//  Created by Phil Starner on 4/22/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit
import DataBridge
import CoreData

class AddFriendsViewController: UIViewController, UITableViewDelegate {
    
    var users = [User]()
    
    var lastSelectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black;
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var context = CoreDataStack.sharedInstance.managedObjectContext!
        let request = NSFetchRequest(entityName: "User")
        let users = context.executeFetchRequest(request, error: nil) as! [User]
        
        return users.count
        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! TableViewCell
        
        
        var context = CoreDataStack.sharedInstance.managedObjectContext!
        let request = NSFetchRequest(entityName: "User")
        let users = context.executeFetchRequest(request, error: nil) as! [User]

        var firstInitial = first(users[indexPath.row].firstName)
        var lastInitial = first(users[indexPath.row].lastName)
        var initials : String = String(firstInitial!) + String(lastInitial!)
        cell.initials?.text = initials
        cell.label?.text = users[indexPath.row].firstName + " " + users[indexPath.row].lastName

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        var context = CoreDataStack.sharedInstance.managedObjectContext!
        var person = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: context) as! User
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if cell.accessoryType == .None {
            cell.accessoryType = .Checkmark
            person.selected = true
        } else {
            cell.accessoryType = .None
            person.selected = false
        }
        
        context.save(nil)
        
        
    }
}
