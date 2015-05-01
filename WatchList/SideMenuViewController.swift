//
//  SideMenuViewController.swift
//  WatchList
//
//  Created by Phil Starner on 4/30/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import Foundation

class SideMenuViewController: UITableViewController {
    
    var menuItems: [String] = ["title", "settings","friends","about"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(menuItems[indexPath.item]) as! UITableViewCell
//        NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        return cell;
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let indexPath:NSIndexPath = self.tableView.indexPathForSelectedRow()!
        let dest:UINavigationController = segue.destinationViewController as! UINavigationController
        dest.title = menuItems[indexPath.item]
    }
    
    
}