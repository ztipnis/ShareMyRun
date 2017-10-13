//
//  FBUser.swift
//  ShareMyRun
//
//  Created by Zachary Tipnis on 12/29/15.
//  Copyright © 2015 Zachal. All rights reserved.
//

import Foundation
import UIKit

class FBUser {
    
    var facebookid:NSString = ""
    var username:NSString = ""
    //var userEmail:NSString = ""
    
    func returnUserData()
    {
        let params = ["fields": "id, name, friends"]
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: params)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                //print("fetched user: \(result)")
                self.facebookid = result.valueForKey("id")as! NSString
                self.username = result.valueForKey("name") as! NSString
                print("User Name is: \(self.username) and ID is: \(self.facebookid)")
               // self.userEmail = result.valueForKey("email") as! NSString
               // print("User Email is: \(self.userEmail)")
            }
        })
    }
    
}