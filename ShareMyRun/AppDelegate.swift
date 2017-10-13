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
import Fabric
import Crashlytics
//import FBSDKCoreKit
//import Seam



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CDEPersistentStoreEnsembleDelegate {

  var window: UIWindow?
  //var smStore: SMStore?
    var ensemble:CDEPersistentStoreEnsemble!

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    BuddyBuildSDK.setup()
    
    // Override point for customization after application launch.
    
    let navigationController = window!.rootViewController as! UINavigationController
    let controller = navigationController.topViewController as! HomeViewController
    controller.managedObjectContext = managedObjectContext
    Fabric.with([Crashlytics.self])
    
    let file = CDEICloudFileSystem(ubiquityContainerIdentifier: nil)
    let modelURL = NSBundle.mainBundle().URLForResource("ShareMyRun", withExtension: "momd")!
    let storeurl = self.applicationDocumentsDirectory.URLByAppendingPathComponent("ShareMyRun.sqlite")
    ensemble = CDEPersistentStoreEnsemble(ensembleIdentifier: "com.zachal.ShareMyRun.defaultStore", persistentStoreURL: storeurl, managedObjectModelURL: modelURL, cloudFileSystem: file)
    ensemble.delegate = self
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "localSaveOccurred:", name: CDEMonitoredManagedObjectContextDidSaveNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "cloudDataDidDownload:", name: CDEICloudFileSystemDidDownloadFilesNotification, object: nil)
    
    syncWithCompletion { completed in
        if completed {
            print("SUCCESSS")
        }
        else {
            print("FAIL")
        }
    }

    
    return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    
  }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject])
    {
        //self.smStore?.handlePush(userInfo: userInfo)
    }
    
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(
                application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    
    print("Did Enter Background Save from App Delegate")
    
    let identifier = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
    saveContext()
    
    syncWithCompletion { (completed) -> Void in
        if completed {
            UIApplication.sharedApplication().endBackgroundTask(identifier)
        }
    }
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    
    syncWithCompletion { (completed) -> Void in
        
    }
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    saveContext()
  }

  // MARK: - Core Data stack

  lazy var applicationDocumentsDirectory: NSURL = {
      // The directory the application uses to store the Core Data store file. This code uses a directory named "com.zedenem.MoonRunner" in the application's documents Application Support directory.
      let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
      return urls.last! as NSURL
  }()

  lazy var managedObjectModel: NSManagedObjectModel = {
      // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
      let modelURL = NSBundle.mainBundle().URLForResource("ShareMyRun", withExtension: "momd")!
      return NSManagedObjectModel(contentsOfURL: modelURL)!
  }()

  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
      // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
      // Create the coordinator and store

      var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
      let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("ShareMyRun.sqlite")
      var error: NSError? = nil
      var failureReason = "There was an error creating or loading the application's saved data."
      do {
          try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        //self.smStore = try coordinator!.addPersistentStoreWithType(SeamStoreType, configuration: nil, URL: url, options: nil) as? SMStore
      } catch var error1 as NSError {
          error = error1
          coordinator = nil
          // Report any error we got.
          var dict = [NSObject: AnyObject]()
          dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
          dict[NSLocalizedFailureReasonErrorKey] = failureReason
          dict[NSUnderlyingErrorKey] = error
          error = NSError(domain: "com.zachal.ShareMyRun.error", code: 0001, userInfo: dict)
          // Replace this with code to handle the error appropriately.
          // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
          NSLog("Unresolved error \(error), \(error!.userInfo)")
          abort()
      } catch {
          fatalError()
      }
      
      return coordinator
  }()
    
    func localSaveOccurred(note:NSNotification) {
        syncWithCompletion { (completed) -> Void in
            
        }
    }
    
    func cloudDataDidDownload(note:NSNotification) {
        syncWithCompletion { (completed) -> Void in
            print("items from iCloud arrived")
        }
    }
    
    func syncWithCompletion(completion:(completed:Bool) -> Void) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        if !ensemble.leeched {
            ensemble.leechPersistentStoreWithCompletion(nil)
        }
        else {
            ensemble.mergeWithCompletion{ error in
                if error != nil {
                    print("cannot merge \(error!.localizedDescription)")
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    completion(completed: false)
                }
                else {
                    print("merged")
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    completion(completed: true)
                }
            }
        }
    }

  lazy var managedObjectContext: NSManagedObjectContext? = {
      // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
      let coordinator = self.persistentStoreCoordinator
      if coordinator == nil {
          return nil
      }
      var managedObjectContext = NSManagedObjectContext()
      managedObjectContext.persistentStoreCoordinator = coordinator
      return managedObjectContext
  }()
    
    // MARK: - Ensemble Delegate Methods
    
    func persistentStoreEnsemble(ensemble: CDEPersistentStoreEnsemble!, didSaveMergeChangesWithNotification notification: NSNotification!) {
        
        managedObjectContext!.performBlockAndWait { () -> Void in
            self.managedObjectContext!.mergeChangesFromContextDidSaveNotification(notification)
        }
    }
    
    func persistentStoreEnsemble(ensemble: CDEPersistentStoreEnsemble!, globalIdentifiersForManagedObjects objects: [AnyObject]!) -> [AnyObject]! {
        return (objects as NSArray).valueForKeyPath("uniqueIdentifier") as! [AnyObject]
    }

  // MARK: - Core Data Saving support

  func saveContext () {
      if let moc = self.managedObjectContext {
          var error: NSError? = nil
          if moc.hasChanges {
              do {
                  try moc.save()
              } catch let error1 as NSError {
                  error = error1
                  // Replace this implementation with code to handle the error appropriately.
                  // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                  NSLog("Unresolved error \(error), \(error!.userInfo)")
                  abort()
              }
          }
      }
  }
    

}

