//
//  LoginViewController.swift
//  WatchList
//
//  Created by Lee Strasheim on 5/1/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit



class LoginViewController: UIViewController {

    var error = ""

    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func loginButton(sender: AnyObject) {
        
        var username = usernameField.text
        var password = passwordField.text
        
        if username == "" || password == "" {
            error = "You must enter a username and password"
            
            displayAlert("Oops!", error: error)
            
        } else {
            
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            PFUser.logInWithUsernameInBackground(username!, password:password!) {
                (user, signupError) -> Void in
                

                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if signupError == nil {
                    
                    print("logged in")
    
                    self.performSegueWithIdentifier("mainView", sender: self)
                    
                } else {
                    
                    if let errorString = signupError!.userInfo["error"] as? NSString {
                        
                        self.error = errorString as! String
                        
                    } else {
                        
                        self.error = "Please try again later."
                        
                    }
                    
                    self.displayAlert("Could Not Log In", error: self.error)
                    
                    
                }
            }
            
        }
    }

    
    
    @IBAction func signupButton(sender: AnyObject) {
        self.performSegueWithIdentifier("signupView", sender: self)
    }
    
    @IBAction func logoutFromMainMenu(segue:UIStoryboardSegue) {
        PFUser.logOut()
        print("logged out")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }

    
    override func viewWillAppear(animated: Bool) {
        let currentUser = PFUser.currentUser()
        print(currentUser)
        if currentUser != nil {
            self.performSegueWithIdentifier("mainView", sender: self)
        }
        
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   
    
    func displayAlert(title:String, error:String) {
        
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    


}
