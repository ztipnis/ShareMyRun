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
import CoreLocation
import HealthKit
import MapKit

let DetailSegueName = "RunDetails"

class NewRunViewController: UIViewController {
  var managedObjectContext: NSManagedObjectContext?
  let hkCTRL = HKController()
    var healthManager:HealthManager?
    let healthKitStore:HKHealthStore = HKHealthStore()
  var run: Run!
    var shouldUpdateMapAndDistance:Bool! = true

  @IBOutlet weak var promptLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var paceLabel: UILabel!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var stopButton: UIButton!
  @IBOutlet weak var pauseButton: UIButton!

    @IBOutlet weak var startView: UIView!
    @IBOutlet weak var InfoView: UIView!
  @IBOutlet weak var mapView: MKMapView!
    
    var paused:Bool!
    
  var seconds = 0.0
  var distance = 0.0

  lazy var locationManager: CLLocationManager = {
    var _locationManager = CLLocationManager()
    _locationManager.delegate = self
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest
    _locationManager.activityType = .Fitness

    // Movement threshold for new events
    _locationManager.distanceFilter = 10.0
    return _locationManager
    }()

  lazy var locations = [CLLocation]()
  lazy var timer = NSTimer()

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    startButton.hidden = false
    startButton.alpha = 1.0
    startButton.enabled = true
    promptLabel.hidden = false

    timeLabel.hidden = true
    distanceLabel.hidden = true
    paceLabel.hidden = true
    stopButton.hidden = false
    stopButton.alpha = 0.25
    stopButton.enabled = false
    pauseButton.hidden = false
    pauseButton.alpha = 0.25
    pauseButton.enabled = false

    locationManager.requestAlwaysAuthorization()
    paused = false

    //mapView.hidden = true
    mapView.delegate = self
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    timer.invalidate()
  }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        if (toInterfaceOrientation == .Portrait || toInterfaceOrientation == .PortraitUpsideDown){
            
            startView.hidden = false
            InfoView.hidden = false
            
        }else{
        
            if(toInterfaceOrientation == .LandscapeLeft || toInterfaceOrientation == .LandscapeRight){
                
                startView.hidden = true
                InfoView.hidden = true
            }
        }
    }

  func eachSecond(timer: NSTimer) {
    seconds++

    if (distance < 0.01){
        distance = 0.01
    }

    var min = 0
    var secMutable = round(seconds)
    while secMutable > 59
    {
        min += 1
        secMutable -= 60
    
    }
    timeLabel.text = String(min) + ":"
    let formatter = NSNumberFormatter()
    formatter.minimumIntegerDigits = 2
    var str = formatter.stringFromNumber(secMutable)
    print(str)
    timeLabel.text = timeLabel.text! + str!
    timeLabel.text = timeLabel.text!
    //let distanceQuantity = HKQuantity(unit: HKUnit.mileUnit(), doubleValue: round(distance*100)/100)
    distanceLabel.text = String(round(distance*100)/100)
    print(round(seconds/5), " ", seconds/5)
    if seconds > 29 {
    if(round(seconds/5) == seconds/5){
    
        let pace = (round(((seconds / 60) / distance)*100)/100)
        
        //let paceUnit = HKUnit.minuteUnit().unitDividedByUnit(HKUnit.mileUnit())
        //let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: pace)
        
        let paceSecTotal = pace*60
        var paceSecMutable = round(paceSecTotal)
        var paceMin = 0
        
        while paceSecMutable > 59
        {
            
            paceMin += 1
            paceSecMutable -= 60
            
        }
        
        str = formatter.stringFromNumber(paceSecMutable)
        print(str)
        paceLabel.text = String(paceMin) + ":"
        paceLabel.text = paceLabel.text! + str!
        paceLabel.text = paceLabel.text!
    }
    }
    
  }

  func startLocationUpdates() {
    // Here, the location manager will be lazily instantiated
    locationManager.startUpdatingLocation()
  }

  func saveRun() {
    // 1
    if (managedObjectContext == nil) {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = delegate.managedObjectContext
    }
    let savedRun = NSEntityDescription.insertNewObjectForEntityForName("Run",
      inManagedObjectContext: managedObjectContext!) as! Run
    savedRun.distance = distance
    savedRun.duration = seconds
    savedRun.timestamp = NSDate()
    let points = pow(1.5, distance) / ((round(((seconds / 60) / distance)*100)/100)/9)
    print(points)
    let pointsMutable = NSEntityDescription.insertNewObjectForEntityForName("Score", inManagedObjectContext: managedObjectContext!) as! Score
    pointsMutable.points = points
    savedRun.workout = saveRunningWorkout(seconds, pace: ((distance*1600)/(seconds/60)), endDate: savedRun.timestamp!, distance: distance, distanceUnit: HKUnit.mileUnit(), completion: { (success, error ) -> Void in
        if( success )
        {
            print("Workout saved!")
        }
        else if( error != nil ) {
            print("\(error)")
        }
    })


    // 2
    var savedLocations = [Location]()
    for location in locations {
      let savedLocation = NSEntityDescription.insertNewObjectForEntityForName("Location",
        inManagedObjectContext: managedObjectContext!) as! Location
      savedLocation.timestamp = location.timestamp
      savedLocation.latitude = location.coordinate.latitude
      savedLocation.longitude = location.coordinate.longitude
      savedLocations.append(savedLocation)
    }

    savedRun.locations = NSOrderedSet(array: savedLocations)
    run = savedRun

    (UIApplication.sharedApplication().delegate as! AppDelegate).syncWithCompletion{(completed) -> Void in
            if completed{
                
                // 3
                var error: NSError?
                let success: Bool
                do {
                    try self.managedObjectContext!.save()
                    success = true
                } catch let error1 as NSError {
                    error = error1
                    success = false
                }
                if !success {
                    print("Could not save the run! " + (error?.description)!)
                }

            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .AuthorizedAlways)
    }
    
  @IBAction func startPressed(sender: AnyObject) {
    startButton.hidden = false
    startButton.enabled = false
    startButton.alpha = 0.25
    InfoView.hidden = false
    promptLabel.hidden = true

    timeLabel.hidden = false
    distanceLabel.hidden = false
    paceLabel.hidden = false
    stopButton.alpha = 1.0
    pauseButton.alpha = 1.0
    stopButton.enabled = true
    pauseButton.enabled = true
    
    
    if (paused != true) {
        seconds = 0.0
        distance = 0.0
        paused = false
        locations.removeAll(keepCapacity: false)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        mapView.hidden = false

    
    }
    timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "eachSecond:", userInfo: nil, repeats: true)
    startLocationUpdates()
}
    @IBAction func pausePressed(sender: AnyObject) {
        paused = true
        shouldUpdateMapAndDistance = false
        locationManager.stopUpdatingLocation()
        timer.invalidate()
        startButton.hidden = false
        startButton.enabled = true
        startButton.alpha = 1.0
        InfoView.hidden = false
        promptLabel.hidden = true
        
        timeLabel.hidden = false
        distanceLabel.hidden = false
        paceLabel.hidden = false
        stopButton.alpha = 1.0
        pauseButton.alpha = 0.25
        stopButton.enabled = true
        pauseButton.enabled = false

    }

  @IBAction func stopPressed(sender: AnyObject) {
    timer.invalidate()
    locationManager.stopUpdatingLocation()
    let actionSheet = UIActionSheet(title: "Run Stopped", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Save", "Discard")
    actionSheet.actionSheetStyle = .Default
    actionSheet.showInView(view)
    timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "eachSecond:", userInfo: nil, repeats: true)
    startLocationUpdates()
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let detailViewController = segue.destinationViewController as? DetailViewController {
      detailViewController.run = run
        //self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
  }
    func saveRunningWorkout(duration:Double , pace:Double, endDate:NSDate , distance:Double, distanceUnit:HKUnit ,
        completion: ( (Bool, NSError!) -> Void)!) -> HKWorkout {
            
            let startTime = endDate.dateByAddingTimeInterval(-1 * duration)
            
            let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
            var weightkilo:Double = 0.0
            // 2. Call the method to read the most recent weight sample
            self.healthManager?.readMostRecentSample(sampleType!, completion: { (mostRecentWeight, error) -> Void in
                
                if( error != nil )
                {
                    print("Error reading weight from HealthKit Store: \(error.localizedDescription)")
                    return;
                }
                
                // 3. Format the weight to display it on the screen
                let weight = mostRecentWeight as? HKQuantitySample;
                if let kilograms = weight?.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo)) {
                    print("Kilos",  kilograms)
                    weightkilo = kilograms
                }
            });
            let VO2 = (0.2*(pace))+3.5
            let kCalMin = (4.9 * weightkilo * VO2/1000)
            let kCal = (kCalMin)*(duration/60)
            let workout = HKWorkout(activityType: HKWorkoutActivityType.Running, startDate: startTime, endDate: endDate, duration: duration, totalEnergyBurned: HKQuantity(unit: HKUnit.calorieUnit(), doubleValue: kCal), totalDistance: HKQuantity(unit: HKUnit.mileUnit(), doubleValue: distance), metadata: nil)
            healthKitStore.saveObject(workout, withCompletion: { (success, error) -> Void in
                if( error != nil  ) {
                    // Error saving the workout
                    completion(success,error)
                    var error: NSError?
                    let success: Bool
                    do {
                        try self.managedObjectContext!.save()
                        success = true
                    } catch let error1 as NSError {
                        error = error1
                        success = false
                    }
                    if !success {
                        print("Could not save the run! " + (error?.description)!)
                    }
                    
                }
                else {
                    // Workout saved
                    completion(success,nil)
                    
                }
            })
            
            return workout
    }

}

// MARK: - MKMapViewDelegate
extension NewRunViewController: MKMapViewDelegate {
  func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    if !overlay.isKindOfClass(MKPolyline) {
      return MKOverlayRenderer()
    }

    let polyline = overlay as! MKPolyline
    let renderer = MKPolylineRenderer(polyline: polyline)
    renderer.strokeColor = UIColor.greenColor()
    renderer.lineWidth = 3
    return renderer
  }
}

// MARK: - CLLocationManagerDelegate
extension NewRunViewController: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    for location in locations {
      let howRecent = location.timestamp.timeIntervalSinceNow

      if abs(howRecent) < 30 && location.horizontalAccuracy < 75 {
        //update distance
        if self.locations.count > 0 {
            if (shouldUpdateMapAndDistance == true) {
          distance += (location.distanceFromLocation(self.locations.last!) * 0.000621371)
            }
          var coords = [CLLocationCoordinate2D]()
          coords.append(self.locations.last!.coordinate)
          coords.append(location.coordinate)

          let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
          mapView.setRegion(region, animated: true)

            if (shouldUpdateMapAndDistance == true) {
          mapView.addOverlay(MKPolyline(coordinates: &coords, count: coords.count))
            }else{
                shouldUpdateMapAndDistance = true
            }
        }

        //save location
        self.locations.append(location)
      }
    }
  }
}

// MARK: - UIActionSheetDelegate
extension NewRunViewController: UIActionSheetDelegate {
  func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
    //save
    if buttonIndex == 1 {
      saveRun()
      performSegueWithIdentifier(DetailSegueName, sender: self)
    }
      //discard
    else if buttonIndex == 2 {
      navigationController?.popToRootViewControllerAnimated(true)
    }
  }
}
