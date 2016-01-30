//
//  ParseSelectFriendsViewController.swift
//  WatchList
//
//  Created by Lee Strasheim on 5/28/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit

class ParseSelectFriendsViewController: PFQueryTableViewController {

    @IBOutlet weak var menuBarButton: UIBarButtonItem!

    let user = PFUser.currentUser()!
    
    var trackingArray = [String]()
    var friendsArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black;
        
        
//        if self.revealViewController() != nil {
//            menuBarButton.target = self.revealViewController()
//            menuBarButton.action = "revealToggle:"
//            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
//        }
//        self.revealViewController().rearViewRevealWidth = 160
        
        PFUser.currentUser()?.fetchInBackgroundWithBlock({ (user, error) -> Void in
            if error == nil {
               let updatedUser = user as! PFUser
                self.trackingArray = updatedUser["tracking"] as! [String]
                self.friendsArray = updatedUser["friends"] as! [String]
                print("new tracking users are \(self.trackingArray)")
                self.loadObjects()
            }
        })
        


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
        super.init(coder: aDecoder)!
        
        // Configure the PFQueryTableView
        self.parseClassName = "WolfPack"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
    }
    
    // Define the query that will provide the data for the table view
    override func queryForTable() -> PFQuery{
        let query = PFQuery(className: "WolfPack")
        query.whereKey("username", notEqualTo: user.username!)
        query.whereKey("username", containedIn: friendsArray )
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
                print("image loaded")
            })
        }
        
        if self.trackingArray.contains((object?["username"] as! String)) {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }

        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ParseSelectFriendCell;
        
        let name = cell.username!.text
        
        if cell.accessoryType == .None {
            cell.accessoryType = .Checkmark
            updateParseUser(name!, selected: true)
        } else {
            cell.accessoryType = .None
            updateParseUser(name!, selected: false)
        }

        
    }

    func updateParseUser(user: String, selected: Bool) {
        if !trackingArray.contains(user) && selected {
            trackingArray.append(user)
        } else {
            for var i=0; i < trackingArray.count;i++ {
                if trackingArray[i] == user {
                    print("remove tracking for \(user)")
                    trackingArray.removeAtIndex(i)
                    
                }
            }
        }
        self.user["tracking"] = self.trackingArray
        
        PFUser.currentUser()?.saveInBackgroundWithBlock({ (success, error) -> Void in
            print("user updated")
            NSNotificationCenter.defaultCenter().postNotificationName("UpdateUser", object: nil)
        })

    }

}
