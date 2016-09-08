//
//  SideMenuViewController.swift
//  WatchList
//
//  Created by Phil Starner on 4/30/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import Foundation

class SideMenuViewController: UITableViewController {
    
    var menuItems: [String] = ["title","friends", "settings","logout","about"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tableView.backgroundColor =  UIColor(patternImage: UIImage(named: "star_bg.png")!)
        
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
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(menuItems[indexPath.item])!
        
        return cell;
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
//        let indexPath:NSIndexPath = self.tableView.indexPathForSelectedRow()!
//        let dest:UINavigationController = segue.destinationViewController as! UINavigationController
//        dest.title = menuItems[indexPath.item]
    }
 
    @IBAction func headHome() {
        print("Button seen.  Trigging exit segue manually...")
        self.performSegueWithIdentifier("goBackHome", sender: self)
    }
    
    
}