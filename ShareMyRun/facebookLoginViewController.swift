//
//  facebookLoginViewController.swift
//  ShareMyRun
//
//  Created by Zachary Tipnis on 12/15/15.
//  Copyright © 2015 Zachal. All rights reserved.
//

import Foundation
import UIKit
//import FBSDKCoreKit
//import FBSDKLoginKit

class facebookLoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userLoginStatusChanged", name: FBSDKProfileDidChangeNotification, object: nil)
        let textView = UILabel(frame: CGRectMake(view.bounds.minX, view.bounds.minY, view.bounds.width, view.bounds.height))
        textView.text = "Welcome to ShareMyRun"
        textView.lineBreakMode = .ByWordWrapping
        textView.numberOfLines = 10
        textView.textAlignment = .Center
        textView.textColor = UIColor.whiteColor()
        textView.font = textView.font.fontWithSize(51.0)
        textView.shadowColor = UIColor.blackColor()
        textView.shadowOffset = CGSize(width: 0, height: -1)
        let imageView = UIImageView(image: UIImage(named: "IMG_0032"))
        imageView.center = view.center
        imageView.frame = CGRectMake(view.bounds.minX, view.bounds.minY, view.bounds.width, view.bounds.height)
        imageView.contentMode = .ScaleAspectFill
        self.view.addSubview(imageView)
        let UIBlur = UIBlurEffect(style: .Light)
        let blurredView = UIVisualEffectView(effect: UIBlur)
        blurredView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        blurredView.frame = CGRectMake(0, 0, imageView.bounds.width, imageView.bounds.height)
        blurredView.alpha = 1
        imageView.addSubview(blurredView)
        self.view.addSubview(textView)
        let loginView : FBSDKLoginButton = FBSDKLoginButton()
        loginView.frame = CGRectMake((view.bounds.maxX / 2)-(loginView.bounds.width / 2), view.bounds.maxY - (loginView.bounds.height + 15), loginView.bounds.width, loginView.bounds.height)
        self.view.addSubview(loginView)
        //loginView.center = self.view.center
        loginView.readPermissions = ["public_profile", "email", "user_friends", "user_birthday"]
        loginView.delegate = self
    }
    
    func userLoginStatusChanged() {
        
        print(FBSDKProfile.currentProfile())
        
    
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                print("True")
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                print("User Email is: \(userEmail)")
            }
        })
    }

}