//
//  SignupViewController.swift
//  WatchList
//
//  Created by Lee Strasheim on 5/5/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit
import MobileCoreServices
import Parse



class SignupViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {


    var error = ""
    
    var hasImage = false
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var image: UIImageView!
    
    
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBAction func cancelButton(sender: AnyObject) {
        self.performSegueWithIdentifier("loginView", sender: self)
    }
    
    @IBAction func photoButton(sender: AnyObject) {
        showImagePickerActionSheet()
        //choosePhoto()
    }
    
    
    @IBAction func signupButton(sender: AnyObject) {
        
        if usernameField.text == "" || passwordField.text == "" || emailField.text == "" || hasImage == false {
            self.displayAlert("Oops!", error: "You must complete all fields and choose a profile pic")
        } else {
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            let imageData = UIImagePNGRepresentation(self.image.image!)
            let imageFile = PFFile(name:"profile.png", data:imageData!)
            imageFile.saveInBackgroundWithBlock { (success, error) -> Void in

                var uuid = NSUUID().UUIDString

                
                if var username = self.usernameField.text,  var email = self.emailField.text{
                    username = username.lowercaseString
                    email = email.lowercaseString
                    
                    var trackingArray = [""]
                    
                    var user = PFUser()
                    user.username = username
                    user.password = self.passwordField.text
                    user.email = email
                    user.setObject(imageFile, forKey: "profilepic")
                    user.setObject(uuid, forKey: "guid")
                    
                    user.signUpInBackgroundWithBlock {
                        (success, signupError) -> Void in
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        
                        if signupError == nil {
                            
                            print("logged in")
                            
                            var wolfpack = PFObject(className:"WolfPack")
                            wolfpack["username"] = username
                            wolfpack["userId"] = user.objectId
                            wolfpack["profilepic"] = imageFile
                            wolfpack["friends"] = [String]()
                            wolfpack["tracking"] = [String]()
                            
                            wolfpack.saveInBackgroundWithBlock {
                                (success: Bool, error: NSError?) -> Void in
                                if (success) {
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.performSegueWithIdentifier("signupToMainView", sender: self)
                                    }
                                } else {
                                    print("Problem creating WolfPack object")
                                }
                            }
                            
                        } else {
                            
                            if let errorString = signupError!.userInfo["error"] {
                                
                                self.error = errorString as! String
                                
                            } else {
                                
                                self.error = "Please try again later."
                                
                            }
                            
                            self.displayAlert("Oops!", error: self.error)
                            
                            
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func displayAlert(title:String, error:String) {
        
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            //self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func showImagePickerActionSheet(){
        let action : UIAlertController = UIAlertController(title: "Alert", message: "Select Option", preferredStyle: UIAlertControllerStyle.ActionSheet)
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
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.mediaTypes = [kUTTypeImage as String]
            picker.allowsEditing = true
            self.presentViewController(picker, animated: true, completion: nil)
            
        }
        else{
            NSLog("No Camera.")
        }
    }
    
    func choosePhoto() {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)){
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            picker.mediaTypes = [kUTTypeImage as String]
            picker.allowsEditing = true
            self.presentViewController(picker, animated: true, completion: nil)
            
            
        }
        else{
            NSLog("No Photo Library.")
        }
    }
    
    // MARK: - Delegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        NSLog("Did Finish Picking")
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        var originalImage:UIImage?, editedImage:UIImage?, imageToSave:UIImage?
        
        // Handle a still image capture
        
        
        editedImage = info[UIImagePickerControllerEditedImage]as! UIImage?
        originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage?
        
        if ( editedImage == nil ) {
            imageToSave = editedImage
        } else {
            imageToSave = originalImage
        }
        
        imageToSave!.resize(CGSizeMake(100, 100), completionHandler: { [weak self](resizedImage, data) -> () in

            
            self!.image.layer.cornerRadius = 50
            self!.image.layer.masksToBounds = true
            self!.image.image = resizedImage
            
            self!.hasImage = true
            
            self!.dismissViewControllerAnimated(true, completion: nil)
            
            })
        

        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    


}


extension UIImage {
    public func resize(size:CGSize, completionHandler:(resizedImage:UIImage, data:NSData)->()) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            let newSize:CGSize = size
            let rect = CGRectMake(0, 0, newSize.width, newSize.height)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            self.drawInRect(rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let imageData = UIImageJPEGRepresentation(newImage, 0.5)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler(resizedImage: newImage, data:imageData!)
            })
        })
    }
}

