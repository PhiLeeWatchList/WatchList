//
//  LoginViewController.swift
//  WatchList
//
//  Created by Lee Strasheim on 5/1/15.
//  Copyright (c) 2015 PhiLee. All rights reserved.
//

import UIKit
import Parse
import ParseUI


class LoginViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {

    var loginViewController: PFLogInViewController! = PFLogInViewController()
    var signUpViewController: PFSignUpViewController! = PFSignUpViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.loginViewController.delegate = self
        
        if PFUser.currentUser() == nil {
            self.loginViewController.fields = (PFLogInFields.UsernameAndPassword | PFLogInFields.LogInButton | PFLogInFields.SignUpButton | PFLogInFields.PasswordForgotten)
        
            var logInLogoTitle = UILabel()
            logInLogoTitle.text = "WatchList"
            
            self.loginViewController.logInView!.logo = logInLogoTitle
            
            self.signUpViewController.delegate = self
            
            var signUpLogoTitle = UILabel()
            signUpLogoTitle.text = "WatchList"
            
            self.signUpViewController.signUpView!.logo = signUpLogoTitle
            
            self.signUpViewController.delegate = self
            
            self.loginViewController.signUpController = self.signUpViewController
            
            self.presentViewController(self.loginViewController, animated: true, completion: nil)
        
        } else {
            println(PFUser.currentUser()?.username)
            self.performSegueWithIdentifier("mainView", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        println("trying to login...")
        if (!username.isEmpty || !password.isEmpty) {
            return true
        } else {
            return false
        }
    }
    
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        println("logged in user...")
        self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("mainView", sender: self)
    }

    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        println("Failed to login")
    }

    
    // MARK: Parse Sign Up
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
        println("Failed to sign up.....")
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) {
        println("User dismissed signup")
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func unwindToSegue (segue : UIStoryboardSegue) {
        PFUser.logOut()
        println("logged out....")
    }
    

}
