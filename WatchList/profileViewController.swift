//
//  profileViewController.swift
//  WatchList
//
//  Created by Lee Strasheim on 6/16/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit
import MobileCoreServices
import Parse
import ParseUI


class profileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var profilePic: PFImageView!
    
    @IBOutlet weak var username: UILabel!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Update Profile"
        
        let image = UIImage(named: "menu.png")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .Plain, target: self, action: "presentLeftMenuViewController")
        
        var user = PFUser.currentUser() as PFUser!
        
        self.username.text = user.username
        
        let userPicture = user["profilepic"] as! PFFile
        
        self.profilePic.layer.cornerRadius = 50
        self.profilePic.layer.masksToBounds = true
        self.profilePic.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.profilePic.layer.borderWidth = 2
        
        self.profilePic.userInteractionEnabled = true

        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("imageTapped:"))
        self.profilePic.addGestureRecognizer(tapRecognizer)
        
        userPicture.getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
            if (error == nil) {
                let image = UIImage(data:data!)
                self.profilePic.image = image
            }
        }
        
    }

    func imageTapped(gestureRecognizer: UITapGestureRecognizer) {
        let tappedImageView = gestureRecognizer.view!
        self.showImagePickerActionSheet()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showImagePickerActionSheet(){
        var action : UIAlertController = UIAlertController(title: "Alert", message: "Select Option", preferredStyle: UIAlertControllerStyle.ActionSheet)
        action.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: { alertAction in
            //self.dismissViewControllerAnimated(true, completion: nil)
            self.takePhoto()
        }))
        
        action.addAction(UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: { alertAction in
            //self.dismissViewControllerAnimated(true, completion: nil)
            self.choosePhoto()
        }))
        
        action.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {alertAction in
            //self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(action, animated: true, completion: nil)
        
        
    }
    
    
    // MARK: - ActionSheet Methods
    
    func takePhoto() {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            var picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.mediaTypes = [kUTTypeImage]
            picker.allowsEditing = true
            self.presentViewController(picker, animated: true, completion: nil)
            
        }
        else{
            NSLog("No Camera.")
        }
    }
    
    func choosePhoto() {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)){
            var picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            picker.mediaTypes = [kUTTypeImage]
            picker.allowsEditing = true
            self.presentViewController(picker, animated: true, completion: nil)
            
            
        }
        else{
            NSLog("No Photo Library.")
        }
    }
    
    // MARK: - Delegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        var originalImage:UIImage?, editedImage:UIImage?, imageToSave:UIImage?
        
        editedImage = info[UIImagePickerControllerEditedImage]as! UIImage?
        originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage?
        
        if ( editedImage == nil ) {
            imageToSave = editedImage
        } else {
            imageToSave = originalImage
        }
        
        imageToSave!.resize(CGSizeMake(100, 100), completionHandler: { [weak self](resizedImage, data) -> () in
            
            self!.profilePic.image = resizedImage
            
            self!.dismissViewControllerAnimated(true, completion: nil)
            
            let imageData = UIImagePNGRepresentation(self?.profilePic.image)
            let imageFile = PFFile(name:"profile.png", data:imageData)
            imageFile.saveInBackgroundWithBlock({ (sucess:Bool, error:NSError?) -> Void in
                var user = PFUser.currentUser() as PFUser!
                var query = PFQuery(className: "WolfPack")
                query.whereKey("username", equalTo: user.username!)
                query.getFirstObjectInBackgroundWithBlock({ (object:PFObject?, error:NSError?) -> Void in
                    if let object = object as PFObject! {
                        object["profilepic"] = imageFile
                        object.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if success {
                                user.setObject(imageFile, forKey: "profilepic")
                                user.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                                    self!.activityIndicator.stopAnimating()
                                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                    if !success {
                                        println("error updating user's new photo")
                                    }
                                })

                            }
                        })
                        
                    }
                })
                
            })
            
        })
        
        
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
}

