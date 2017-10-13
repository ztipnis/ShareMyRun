//
//  pastRunsViewController.swift
//  ShareMyRun
//
//  Created by Zachary Tipnis on 12/6/15.
//  Copyright © 2015 Zachal. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import HealthKit

class pastRunsViewController : UIViewController, UITableViewDataSource {

    var runs = [NSManagedObject]()
    var indexOfRun:Int! = 0
    var indexPathOfRun:NSIndexPath!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Past Runs"
        tableView.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "Run")
        
        //3
        do {
            
        let results = try managedContext!.executeFetchRequest(fetchRequest)
            runs = results as! [NSManagedObject]
            //print(results)
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
       
    }
    
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            return runs.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        //CODE TO BE RUN ON CELL TOUCH
        print(indexPath.row)
        indexOfRun = indexPath.row
        performSegueWithIdentifier("pastRunDetail", sender: self)
        
    }
    
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            
            let cell =
            tableView.dequeueReusableCellWithIdentifier("Cell")
            
            let run = runs[indexPath.row]
            let runObject = runs[indexPath.row] as! Run
            let timestamp = run.valueForKey("timestamp")
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .MediumStyle
            cell!.textLabel!.text = dateFormatter.stringFromDate(timestamp as! NSDate) + " - " + String(Int(round(runObject.distance?.doubleValue as Double!))) + " mi"
            
            return cell!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailViewController = segue.destinationViewController as? pastRunDetailViewController {
            //detailViewController.run = run
            //self.navigationController?.setNavigationBarHidden(false, animated: true)
            let run = runs[indexOfRun] as! Run
            detailViewController.run = run
            
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            // remove the deleted item from the model
            let actionSheet = UIActionSheet(title: "Remove from HealthKit?", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Yes", "No")
            
            //tableView.reloadData()
            // remove the deleted item from the `UITableView`
            indexOfRun = indexPath.row
            indexPathOfRun = indexPath
            actionSheet.actionSheetStyle = .Default
            actionSheet.showInView(view)
            
        default:
            return
            
        }
    }
}

extension pastRunsViewController: UIActionSheetDelegate {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        //save
        if buttonIndex == 1 {
            let healthKitStore:HKHealthStore = HKHealthStore()
            let theRun = runs[indexOfRun] as! Run
            print (theRun)
            print(theRun.workout)
            let theHKWorkout = theRun.workout as! HKWorkout
            healthKitStore.deleteObject(theHKWorkout, withCompletion: { (success, error ) -> Void in
                if( success )
                {
                    print("Workout deleted!")
                }
                else if( error != nil ) {
                    print("\(error)")
                }
            })

        }
        
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        context.deleteObject(runs[indexPathOfRun.row] as NSManagedObject)
        do{
            try context.save()
        } catch let error1 as NSError {
            print(error1)
        }
        runs.removeAtIndex(indexOfRun)
        self.tableView.deleteRowsAtIndexPaths([indexPathOfRun], withRowAnimation: .Automatic)
    }
}