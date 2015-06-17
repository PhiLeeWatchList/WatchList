//
//  LeftMenuViewController.swift
//  SSASideMenuExample
//
//  Created by Sebastian Andersen on 20/10/14.
//  Copyright (c) 2015 Sebastian Andersen. All rights reserved.
//

import Foundation
import UIKit
import Parse


class LeftMenuViewController: UIViewController {

    var trackingArray = [String]()
    var friendsArray = [String]()
    var objects = [PFObject]()
    var user = PFUser.currentUser()
    
    @IBOutlet weak var tableView: UITableView!

    @IBAction func trackButton(sender: AnyObject) {
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var firstViewController = storyboard.instantiateViewControllerWithIdentifier("FirstViewController") as! UIViewController
        
        sideMenuViewController?.contentViewController = UINavigationController(rootViewController: firstViewController)
        
        sideMenuViewController?.hideMenuViewController()
    }
    
    
    
    @IBAction func profileButton(sender: AnyObject) {
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var profileViewController = storyboard.instantiateViewControllerWithIdentifier("profileView") as! UIViewController
        
        sideMenuViewController?.contentViewController = UINavigationController(rootViewController: profileViewController)
        
        sideMenuViewController?.hideMenuViewController()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        PFUser.currentUser()?.fetchInBackgroundWithBlock({ (user, error) -> Void in
            if error == nil {
                let updatedUser = user as! PFUser
                self.trackingArray = updatedUser["tracking"] as! [String]
                self.friendsArray = updatedUser["friends"] as! [String]
                println("new tracking users are \(self.trackingArray)")
                self.queryForTable()
            }
        })
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func queryForTable(){
        var user = PFUser.currentUser()
        var query = PFQuery(className: "WolfPack")
        query.whereKey("username", notEqualTo: user!.username!)
        query.whereKey("username", containedIn: friendsArray )
        query.orderByAscending("username")
        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
            if let objects = objects {
                self.objects = []
                for object in  objects {
                    self.objects.append(object as! PFObject)
                }
                self.tableView.reloadData()
            }
            
        }
    }
    
    func updateParseUser(username: String, selected: Bool) {
        if !contains(trackingArray, username) && selected {
            trackingArray.append(username)
        } else {
            for var i=0; i < trackingArray.count;i++ {
                if trackingArray[i] == username {
                    println("remove tracking for \(username)")
                    trackingArray.removeAtIndex(i)
                    
                }
            }
        }
        self.user!.setObject(trackingArray, forKey: "tracking")
        
        PFUser.currentUser()?.saveInBackgroundWithBlock({ (success, error) -> Void in
            println("user updated")
            NSNotificationCenter.defaultCenter().postNotificationName("UpdateUser", object: nil)
        })
        
    }
    
}


// MARK : TableViewDataSource & Delegate Methods

extension LeftMenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objects.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TableViewCell
   
        cell.profileImage.layer.borderColor = UIColor.whiteColor().CGColor
        cell.profileImage.layer.borderWidth = 1
        cell.profileImage.layer.cornerRadius = 26
        cell.profileImage.layer.masksToBounds = true
        
        var object = self.objects[indexPath.row]
        
        // Extract values from the PFObject to display in the table cell
        if let username = object["username"] as? String {
            println(username)
            cell.username.text = username
        }
        
        var initialThumbnail = UIImage(named: "logo")
        cell.profileImage.image = initialThumbnail
        if let thumbnail = object["profilepic"] as? PFFile {
            cell.profileImage.file = thumbnail
            cell.profileImage.loadInBackground({ (image, error) -> Void in
                println("image loaded")
            })
        }
        
        if contains(self.trackingArray, object["username"] as! String) {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
     
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TableViewCell;
        
        var name = cell.username.text
        
        if cell.accessoryType == .None {
            cell.accessoryType = .Checkmark
            updateParseUser(name!, selected: true)
        } else {
            cell.accessoryType = .None
            updateParseUser(name!, selected: false)
        }
        
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath],  withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tableView.reloadData()
        }
    }
    
    
}
    