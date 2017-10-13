/*
* Copyright (c) 2015 Zachal LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import CoreData
//import FBSDKCoreKit
//import FBSDKLoginKit

var user:FBUser = FBUser()

class HomeViewController: UIViewController {
    
    @IBOutlet weak var nearbyButton: UIButton!
  var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var PointsLabel: UILabel!
    var points = [NSManagedObject]()
    var totalPoints:Double? = 0
    @IBOutlet weak var welcomeLabel: UILabel!
    
    override func viewDidLoad() {
        print("Testing Lat/Long:" + String(LatLongToMeter(Lat1: 40.738849, Lat2: 40.778422, Long1: -74.256676, Long2: -74.360328)/1600))
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewDidLoad()
        welcomeLabel.adjustsFontSizeToFitWidth = true
        let UIBlur = UIBlurEffect(style: .Light)
        let blurredView = UIVisualEffectView(effect: UIBlur)
        blurredView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        blurredView.frame = CGRectMake(0, 0, bgImgView.bounds.width, bgImgView.bounds.height)
        blurredView.alpha = 1
        bgImgView.addSubview(blurredView)
        
    }
    @IBOutlet weak var nearbyRunsView: nearbyRuns!
    
    override func viewWillAppear(animated: Bool) {
        
        var appDefaults = Dictionary<String, AnyObject>()
        appDefaults["distanceSlider"] = 5
        NSUserDefaults.standardUserDefaults().registerDefaults(appDefaults)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let a = NSUserDefaults.standardUserDefaults().objectForKey("distanceSlider")
        
        if (a != nil) { // This is where it breaks
            print("Distance: " + String(a as! NSNumber))
        }
        
        if !((Reachability.isConnectedToNetwork() == true)) {
            nearbyButton.enabled = false
            nearbyRunsView.alpha = 0.45
        }else{
            nearbyButton.enabled = true
        }
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        if(FBSDKAccessToken.currentAccessToken() != nil){
            print(FBSDKAccessToken.currentAccessToken())
            //username = FBSDKProfile.currentProfile().name
            user.returnUserData()
            
        }else{
            NSLog("performing segue")
            presentViewController(facebookLoginViewController(), animated: true, completion: nil)
        }
        
        totalPoints = 0
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)

        
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "Score")
        
        //3
        do {
            
            let results = try managedContext!.executeFetchRequest(fetchRequest)
            points = results as! [NSManagedObject]
            //print(results)
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        for var n = 0; n < points.count; ++n {
            
            let pointsMutable = points[n] as! Score
            totalPoints! += (pointsMutable.points?.doubleValue)!
        
        }
        PointsLabel.text = "Points: " + String(Int(round(totalPoints!)))
        //NSLog("UserInfo " + user.username as! String + " " + user.userEmail as! String + " " + (user.facebookid as String))

    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        HKController().authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                print("HealthKit authorization received.")
            }
            else
            {
                print("HealthKit authorization denied!")
                if error != nil {
                    print("\(error)")
                }
            }
        }
    }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.destinationViewController.isKindOfClass(NewRunViewController) {
      if let newRunViewController = segue.destinationViewController as? NewRunViewController {
        newRunViewController.managedObjectContext = managedObjectContext
      }
    }
    self.navigationController?.setNavigationBarHidden(false, animated: false)
  }
}