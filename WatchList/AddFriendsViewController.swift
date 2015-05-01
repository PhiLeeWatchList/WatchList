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
        let sortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        let users = context.executeFetchRequest(request, error: nil) as! [User]

        var firstInitial = first(users[indexPath.row].firstName)
        var lastInitial = first(users[indexPath.row].lastName)
        var initials : String = String(firstInitial!) + String(lastInitial!)
        var name = users[indexPath.row].firstName + " " + users[indexPath.row].lastName
        var guid = users[indexPath.row].guid
        cell.initials!.text = initials
        cell.name!.text = name
        cell.guid!.text = guid
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TableViewCell;
        
        var guid = cell.guid!.text
        
        if cell.accessoryType == .None {
            cell.accessoryType = .Checkmark
            saveUserData(guid!, selected: true)
        } else {
            cell.accessoryType = .None
            saveUserData(guid!, selected: false)
        }
        
        
    }
    
    func saveUserData(guid: String, selected: Bool) {
        var context = CoreDataStack.sharedInstance.managedObjectContext!
        
        var fetchRequest = NSFetchRequest(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "guid = %@", guid)
        
        if let fetchResults = context.executeFetchRequest(fetchRequest, error: nil) as? [User] {
            if fetchResults.count != 0{
                
                var managedObject = fetchResults[0]
                managedObject.setValue(true, forKey: "selected")
                
                context.save(nil)
            }
        }
    }
    
    
}
