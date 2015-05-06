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


class SignupViewController: UIViewController, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {


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
        //showImagePickerActionSheet()
        choosePhoto()
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
            
            let imageData = UIImagePNGRepresentation(self.image.image)
            let imageFile = PFFile(name:"profile.png", data:imageData)
            imageFile.saveInBackgroundWithBlock { (success, error) -> Void in
            
                var user = PFUser()
                user.username = self.usernameField.text
                user.password = self.passwordField.text
                user.email = self.emailField.text
                user.setObject(imageFile, forKey: "profilepic")
                
                user.signUpInBackgroundWithBlock {
                    (success, signupError) -> Void in
          
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if signupError == nil {
                        
                        println("logged in")
                        
                        self.navigationController?.popToRootViewControllerAnimated(true)
                        
                    } else {
                        
                        if let errorString = signupError!.userInfo?["error"] as? NSString {
                            
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
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func displayAlert(title:String, error:String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func showImagePickerActionSheet(){
        var action : UIAlertController = UIAlertController(title: "Alert", message: "Select Option", preferredStyle: UIAlertControllerStyle.ActionSheet)
        action.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: { alertAction in
            self.takePhoto()
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        action.addAction(UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: { alertAction in
            self.choosePhoto()
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        action.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {alertAction in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        presentViewController(action, animated: true, completion: nil)
        
        
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
            NSLog("No Camera.")
        }
    }
    
    // MARK: - Delegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
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
        self.image.layer.cornerRadius = 50
        self.image.layer.masksToBounds = true
        self.image.image = editedImage
        
        self.hasImage = true
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }



}