//
//  ParseSelectFriendsViewController.swift
//  WatchList
//
//  Created by Lee Strasheim on 5/28/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ParseSelectFriendsViewController: PFQueryTableViewController {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!

    let user = PFUser.currentUser()
    
    var trackingArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black;
        
        
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.revealViewController().rearViewRevealWidth = 130

        self.trackingArray = self.user["tracking"] as! [String]

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Initialise the PFQueryTable tableview
    override init(style: UITableViewStyle, className: String!) {
        super.init(style: style, className: className)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Configure the PFQueryTableView
        self.parseClassName = "WolfPack"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
    }
    
    // Define the query that will provide the data for the table view
    override func queryForTable() -> PFQuery{
        var query = PFQuery(className: "WolfPack")
        query.whereKey("username", notEqualTo: user!.username!)
        query.orderByAscending("username")
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("FriendCell") as! ParseSelectFriendCell!
        if cell == nil {
            cell = ParseSelectFriendCell(style: UITableViewCellStyle.Default, reuseIdentifier: "FriendCell")
        }
        
        // Extract values from the PFObject to display in the table cell
        if let username = object?["username"] as? String {
            cell.username.text = username
        }
        
        if let photo = object?["profilepic"] as? PFFile {
            cell.profileImage.file = photo
            cell.profileImage.loadInBackground({ (image, error) -> Void in
                println("image loaded")
            })
        }
        
        if let tracking = object?["tracking"] as? Bool {
            if tracking {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ParseSelectFriendCell;
        
        var name = cell.username!.text
        
        if cell.accessoryType == .None {
            cell.accessoryType = .Checkmark
            updateParseUser(name!, selected: true)
        } else {
            cell.accessoryType = .None
            updateParseUser(name!, selected: false)
        }
        
        
    }

    func updateParseUser(user: String, selected: Bool) {
        var query = PFQuery(className: "WolfPack")
        query.whereKey("username", equalTo:user)
        query.getFirstObjectInBackgroundWithBlock { (object:PFObject?, error:NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                println("Successfully updated user \(object).")
                var user = object as PFObject!
                user["tracking"] = selected
                user.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success {
                        println("\(user) tracking updated to \(selected)")
                    }
                })
                
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
            
        }
    }

}
