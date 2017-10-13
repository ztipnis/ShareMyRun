//
//  nearbyRunsViewController.swift
//  ShareMyRun
//
//  Created by Zachary Tipnis on 12/29/15.
//  Copyright © 2015 Zachal. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

infix operator ^^ { }
func ^^ (radix: Int, power: Int) -> Int {
    return Int(pow(Double(radix), Double(power)))
}

class nearbyRunsViewController : UIViewController, UITableViewDataSource {
    
    var json:[JSON] = [JSON]()
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .Fitness
        
        // Movement threshold for new events
        _locationManager.distanceFilter = 10.0
        return _locationManager
    }()
    var runs = [NSManagedObject]()
    var indexOfRun:Int! = 0
    var indexPathOfRun:NSIndexPath!
    lazy var refreshControl: UIRefreshControl = {
        var refrCtrl = UIRefreshControl()
        refrCtrl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refrCtrl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        return refrCtrl
    }()
    var dist: Int {
        var appDefaults = Dictionary<String, AnyObject>()
        appDefaults["distanceSlider"] = 5
        NSUserDefaults.standardUserDefaults().registerDefaults(appDefaults)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let a = NSUserDefaults.standardUserDefaults().objectForKey("distanceSlider")
        
        if (a != nil) { // This is where it breaks
            let distmut = (a as! NSNumber)
            //print("Distance: " + String(distmut))
            return Int(distmut)
        }else{
            return 5
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.addSubview(refreshControl)
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if Reachability.isConnectedToNetwork() == true {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let userPasswordString = "admin:Catfish99"
        let userPasswordData = userPasswordString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64EncodedCredential = userPasswordData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        let authString = "Basic \(base64EncodedCredential)"
        config.HTTPAdditionalHeaders = ["Authorization" : authString]
        let session = NSURLSession(configuration: config)
        
        var running = false
        let url = NSURL(string: "https://smrs.zachal.com/runs.json")
        let task = session.dataTaskWithURL(url!) {
            (let data, let response, let error) in
            if let _ = response as? NSHTTPURLResponse {
                for (_,subJson):(String, JSON) in JSON(data: data!) {
                    self.json.append(subJson)
                }
            }
            running = false
        }
        
        running = true
        task.resume()
        
        while running {
            //print("waiting...")
            usleep(UInt32(10^^4))
        }
            let locManager = self.locationManager
            locManager.requestAlwaysAuthorization()
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.startUpdatingLocation()
        }else{
            
            
            presentViewController(HomeViewController(), animated: true, completion: {})
        
        }
        title = "Runs Within \(String(self.dist))mi"
        tableView.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: "Cell")

    }
    
    func refresh(sender:AnyObject)
    {
        
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        if Reachability.isConnectedToNetwork() == true {
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let userPasswordString = "admin:Catfish99"
            let userPasswordData = userPasswordString.dataUsingEncoding(NSUTF8StringEncoding)
            let base64EncodedCredential = userPasswordData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
            let authString = "Basic \(base64EncodedCredential)"
            config.HTTPAdditionalHeaders = ["Authorization" : authString]
            let session = NSURLSession(configuration: config)
            self.json.removeAll()
            var running = false
            let url = NSURL(string: "https://smrs.zachal.com/runs.json")
            let task = session.dataTaskWithURL(url!) {
                (let data, let response, let error) in
                if let _ = response as? NSHTTPURLResponse {
                    for (_,subJson):(String, JSON) in JSON(data: data!) {
                        self.json.append(subJson)
                    }
                }
                running = false
            }
            
            running = true
            task.resume()
            
            while running {
                //print("waiting...")
                usleep(UInt32(10^^4))
            }
            self.locationManager.startUpdatingLocation()
        }else{
            
            self.refreshControl.endRefreshing()
            
        }
        // Code to refresh table view
    }
    
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            return json.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        //CODE TO BE RUN ON CELL TOUCH
        print(indexPath.row)
        indexOfRun = indexPath.row
        performSegueWithIdentifier("showNearbyRunDetail", sender: self)
        
    }
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            
            let cell =
            tableView.dequeueReusableCellWithIdentifier("Cell")
            
            let run = json[indexPath.row]
            //var runObject:Run = Run()
            
            //let timestamp = run["timestamp"]
            //let dateFormatter = NSDateFormatter()
            //dateFormatter.dateStyle = .MediumStyle
            //cell!.textLabel!.text = dateFormatter.stringFromDate(timestamp as! NSDate) + " - " + String(Int(round(runObject.distance?.doubleValue as Double!))) + " mi"
            let distance:Double = round((run["distance"].doubleValue)*10)/10
            cell!.textLabel!.text = String(distance) + "mi"
            
            return cell!
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailViewController = segue.destinationViewController as? nearbyRunDetailViewController {
            //detailViewController.run = run
            //self.navigationController?.setNavigationBarHidden(false, animated: true)
            let jsonData = json[indexOfRun]
            let run:RunUnmanaged = RunUnmanaged()
            let distmut = jsonData["distance"].doubleValue
            run.distance = distmut
            run.duration = jsonData["duration"].doubleValue
            run.timestamp = NSDate(timeIntervalSince1970: jsonData["timestamp"].doubleValue)
            var locationArray:[LocationUnmanaged] = [LocationUnmanaged]()
            
            for var n = 0; n < jsonData["locations"].count; ++n {
            
                let locationObject = LocationUnmanaged()
                let location = jsonData["locations"][n]
                locationObject.longitude = location["longitude"].doubleValue
                locationObject.latitude = location["latitude"].doubleValue
                locationObject.timestamp = NSDate(timeIntervalSince1970: location["timestamp"].doubleValue)
                locationArray.append(locationObject)
                
            }
            run.locations = NSOrderedSet(array: locationArray)
            detailViewController.run = run
            
        }
    }
}

extension nearbyRunsViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locManager = locationManager
        var currentLocation = CLLocation!()
        currentLocation = locManager.location
        let currLat = currentLocation.coordinate.latitude
        let currLong = currentLocation.coordinate.longitude
        //print(currLat,currLong)
        var removeFromList:[Int] = [Int]()
        for (index, subJson):(Int, JSON) in self.json.enumerate() {
            var shouldRemove = true
            
            for var n = 0; n < subJson["locations"].count; ++n {
                
                let location = subJson["locations"][n]
                let long = location["longitude"].doubleValue
                let lat = location["latitude"].doubleValue
                //print (LatLongToMeter(Lat1: lat, Lat2: currLat, Long1: long, Long2: currLong))
                if ((LatLongToMeter(Lat1: lat, Lat2: currLat, Long1: long, Long2: currLong)) <= (Double(self.dist) * 1600) || shouldRemove == false){
                    
                    shouldRemove = false
                }
                
            }
            
            if ( shouldRemove == true ){
                removeFromList.append(index)
            }
            
            //print(index)
        }
        print(removeFromList)
        while removeFromList.count > 0 {
            self.json.removeAtIndex(removeFromList.maxElement()!)
            removeFromList.removeAtIndex(removeFromList.count - 1)
            tableView.reloadData()
        }
        self.refreshControl.endRefreshing()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        manager.stopUpdatingLocation()
    }
}