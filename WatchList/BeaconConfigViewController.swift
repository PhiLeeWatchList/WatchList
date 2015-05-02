//
//  BeaconConfigViewController.swift
//  WatchList
//
//  Created by Phil Starner on 4/22/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
import MessageUI

class BeaconConfigViewController: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var guidText: UITextField!
    @IBOutlet weak var firstText: UITextField!
    @IBOutlet weak var lastText: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var switchPhil: UISwitch!
    @IBOutlet weak var switchLee: UISwitch!
    @IBOutlet weak var switchLisa: UISwitch!
    @IBOutlet weak var switchJackie: UISwitch!
    @IBOutlet weak var switchChris: UISwitch!
    @IBOutlet weak var switchForrest: UISwitch!
    @IBOutlet weak var switchiPad: UISwitch!
    @IBOutlet weak var switchJanna: UISwitch!
    
    var majorInt:UInt16 = 0
    var minorInt:UInt16 = 0
    var first:String = ""
    var last:String = ""
    var guid:String = "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.layoutForDevices()
        
        self.firstText.delegate = self;
        self.lastText.delegate = self;
        
        if self.revealViewController() != nil {
            menuBarButton.target = self.revealViewController()
            menuBarButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        INBeaconService.singleton().stopBroadcasting()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func layoutForDevices() {
        self.newButton.layer.cornerRadius = 6.0
        self.newButton.layer.masksToBounds = true
        self.newButton.layer.borderColor = UIColor.init(red: 112.0/255.0, green: 146.0/255.0, blue: 255.0/255.0, alpha: 1).CGColor
        self.newButton.layer.borderWidth = 1.0
        
        self.firstText.layer.cornerRadius = 6.0
        self.firstText.layer.masksToBounds = true
        self.firstText.layer.borderColor = UIColor.init(red: 112.0/255.0, green: 146.0/255.0, blue: 255.0/255.0, alpha: 1).CGColor
        self.firstText.layer.borderWidth = 1.0
        
        self.lastText.layer.cornerRadius = 6.0
        self.lastText.layer.masksToBounds = true
        self.lastText.layer.borderColor = UIColor.init(red: 112.0/255.0, green: 146.0/255.0, blue: 255.0/255.0, alpha: 1).CGColor
        self.lastText.layer.borderWidth = 1.0
        
        self.doneButton.layer.cornerRadius = 6.0
        self.doneButton.layer.masksToBounds = true
        self.doneButton.layer.borderColor = UIColor.init(red: 112.0/255.0, green: 146.0/255.0, blue: 255.0/255.0, alpha: 1).CGColor
        self.doneButton.layer.borderWidth = 1.0
    }
    
    
    @IBAction func onNewButton(sender: AnyObject) {
        self.randomBeaconValues()
    }
    
    
    
    @IBAction func onDone(sender: AnyObject) {
        //if all fields are good, then segue out and put us into transmit mode.
        NSNotificationCenter.defaultCenter().postNotificationName(GlobalConstants.TRANSMIT_ON, object: nil)
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    @IBAction func onShare(sender: AnyObject) {
        var picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setSubject("WatchList Friend ID")
        
        picker.setMessageBody("Your friend \(self.firstText.text) has sent you a WatchList friend code!  They must really like you! Click the linke below from your iPhone mail and then \(self.firstText.text) will be able to see you around corners!!!!  Insane I know!!! <br><br> <a src=\"watchlist://?udid=\(self.guid)&first=\(self.firstText.text)&last=\(self.lastText.text)\">\(self.firstText.text) \(self.lastText.text)</a> </b> <br> <br> <br>   full url: watchlist://?udid=\(self.guid)&first=\(self.firstText.text)&last=\(self.lastText.text)", isHTML: true)
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func randomBeaconValues() {
        var uuid = NSUUID().UUIDString
        self.guid = uuid
        self.guidText.text = uuid
        
//        self.majorInt = UInt16(arc4random_uniform(65535))
//        self.minorInt = UInt16(arc4random_uniform(65535))
//        
//        println("major: \(self.majorInt), minor \(self.minorInt)")
//        self.firstText.text = String(self.majorInt)
//        self.lastText.text = String(self.minorInt)
    }
    
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func onSwitchPhil(sender: AnyObject) {
        self.storeUUIDToUserDefaults("CB284D88-5317-4FB4-9621-C5A3A49E6150")
        self.storeNameToUserDefaults("Philip Starner")
        self.firstText.text = "Philip"
        self.lastText.text = "Starner"
        
        self.switchLee.setOn(false, animated: true)
        self.switchLisa.setOn(false, animated: true)
        self.switchiPad.setOn(false, animated: true)
        self.switchChris.setOn(false, animated: true)
        self.switchJackie.setOn(false, animated: true)
        self.switchForrest.setOn(false, animated: true)
        self.switchJanna.setOn(false, animated: true)
    }
    
    @IBAction func onSwitchLee(sender: AnyObject) {
        self.storeUUIDToUserDefaults("CB284D88-5317-4FB4-9621-C5A3A49E6151")
        self.storeNameToUserDefaults("Lee Strasheim")
        self.firstText.text = "Lee"
        self.lastText.text = "Strasheim"
        
        self.switchPhil.setOn(false, animated: true)
        self.switchLisa.setOn(false, animated: true)
        self.switchiPad.setOn(false, animated: true)
        self.switchChris.setOn(false, animated: true)
        self.switchJackie.setOn(false, animated: true)
        self.switchForrest.setOn(false, animated: true)
        self.switchJanna.setOn(false, animated: true)
    }
    
    @IBAction func onSwitchLisa(sender: AnyObject) {
        self.storeUUIDToUserDefaults("CB284D88-5317-4FB4-9621-C5A3A49E6152")
        self.storeNameToUserDefaults("Lisa Starner")
        self.firstText.text = "Lisa"
        self.lastText.text = "Starner"
        self.switchPhil.setOn(false, animated: true)
        self.switchLee.setOn(false, animated: true)
        self.switchiPad.setOn(false, animated: true)
        self.switchChris.setOn(false, animated: true)
        self.switchJackie.setOn(false, animated: true)
        self.switchForrest.setOn(false, animated: true)
        self.switchJanna.setOn(false, animated: true)
    }
    
    @IBAction func onSwitchiPad(sender: AnyObject) {
        self.storeUUIDToUserDefaults("CB284D88-5317-4FB4-9621-C5A3A49E6153")
        self.storeNameToUserDefaults("Phil's iPad")
        self.firstText.text = "Phil"
        self.lastText.text = "iPad"
        self.switchPhil.setOn(false, animated: true)
        self.switchLee.setOn(false, animated: true)
        self.switchLisa.setOn(false, animated: true)
        self.switchChris.setOn(false, animated: true)
        self.switchJackie.setOn(false, animated: true)
        self.switchForrest.setOn(false, animated: true)
        self.switchJanna.setOn(false, animated: true)
    }
    
    @IBAction func onSwitchJackie(sender: AnyObject) {
        self.storeUUIDToUserDefaults("CB284D88-5317-4FB4-9621-C5A3A49E6154")
        self.storeNameToUserDefaults("Jackie Kelley")
        self.firstText.text = "Jackie"
        self.lastText.text = "Kelley"
        self.switchPhil.setOn(false, animated: true)
        self.switchLee.setOn(false, animated: true)
        self.switchLisa.setOn(false, animated: true)
        self.switchChris.setOn(false, animated: true)
        self.switchiPad.setOn(false, animated: true)
        self.switchForrest.setOn(false, animated: true)
        self.switchJanna.setOn(false, animated: true)
    }
    
    @IBAction func onSwitchChris(sender: AnyObject) {
        self.storeUUIDToUserDefaults("CB284D88-5317-4FB4-9621-C5A3A49E6155")
        self.storeNameToUserDefaults("Chris Kelley")
        self.firstText.text = "Chris"
        self.lastText.text = "Kelley"
        self.switchPhil.setOn(false, animated: true)
        self.switchLee.setOn(false, animated: true)
        self.switchLisa.setOn(false, animated: true)
        self.switchJackie.setOn(false, animated: true)
        self.switchiPad.setOn(false, animated: true)
        self.switchForrest.setOn(false, animated: true)
        self.switchJanna.setOn(false, animated: true)
    }
    
    @IBAction func onSwitchForrest(sender: AnyObject) {
        self.storeUUIDToUserDefaults("CB284D88-5317-4FB4-9621-C5A3A49E6156")
        self.storeNameToUserDefaults("Forrest Stewart")
        self.firstText.text = "Forrest"
        self.lastText.text = "Stewart"
        self.switchPhil.setOn(false, animated: true)
        self.switchLee.setOn(false, animated: true)
        self.switchLisa.setOn(false, animated: true)
        self.switchJackie.setOn(false, animated: true)
        self.switchiPad.setOn(false, animated: true)
        self.switchChris.setOn(false, animated: true)
        self.switchJanna.setOn(false, animated: true)
    }
    
    @IBAction func onSwitchJanna(sender: AnyObject) {
        self.storeUUIDToUserDefaults("CB284D88-5317-4FB4-9621-C5A3A49E6157")
        self.storeNameToUserDefaults("Janna Stewart")
        self.firstText.text = "Janna"
        self.lastText.text = "Stewart"
        self.switchPhil.setOn(false, animated: true)
        self.switchLee.setOn(false, animated: true)
        self.switchLisa.setOn(false, animated: true)
        self.switchJackie.setOn(false, animated: true)
        self.switchiPad.setOn(false, animated: true)
        self.switchChris.setOn(false, animated: true)
        self.switchForrest.setOn(false, animated: true)
    }
    
    func storeUUIDToUserDefaults(userString: String) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(userString, forKey: GlobalConstants.THIS_DEVICE_TRANSMIT_UUID)
        
        INBeaconService.singleton().changeIdentifier(userString)
    }
    
    func storeNameToUserDefaults(userString: String) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(userString, forKey: GlobalConstants.THIS_DEVICE_TRANSMIT_NAME)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    

}
