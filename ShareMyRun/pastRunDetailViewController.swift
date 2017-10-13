//
//  pastRunDetailViewController.swift
//  ShareMyRun
//
//  Created by Zachary Tipnis on 12/7/15.
//  Copyright © 2015 Zachal. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import HealthKit

class pastRunDetailViewController : UIViewController {
    var run: Run!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var pace:Double!
    var distance:Double!
    var duration:Double!
    var timestamp:NSDate!
    var locSet:NSOrderedSet!
    var postData:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    func shareButton(){
    
        print("Sharing")
        
        postData = createJSON(user.facebookid as String, run: self.run)
        print(postData)
        let actionSheet = UIActionSheet(title: "Are You Sure?", delegate: self, cancelButtonTitle: "No", destructiveButtonTitle: nil, otherButtonTitles: "Yes")
        actionSheet.actionSheetStyle = .Default
        actionSheet.showInView(view)
        
    }
    
    func configureView() {
        let navBarItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "shareButton")
        navigationItem.rightBarButtonItem = navBarItem
        
        let distanceQuantity = HKQuantity(unit: HKUnit.mileUnit(), doubleValue: round(run.distance!.doubleValue*100)/100)
        distanceLabel.text = distanceQuantity.description
        //distanceLabel.text = "Distance: " + String(round(run.distance.doubleValue * 100) / 100) + " mi"
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateLabel.text = dateFormatter.stringFromDate(run.timestamp!)
        
        var min = 0
        var secMutable = round(run.duration!.doubleValue)
        while secMutable > 59
        {
            min += 1
            secMutable -= 60
            
        }
        timeLabel.text =  String(min) + ":"
        let formatter = NSNumberFormatter()
        formatter.minimumIntegerDigits = 2
        var str = formatter.stringFromNumber(secMutable)
        print(str)
        timeLabel.text = timeLabel.text! + str!
        timeLabel.text = timeLabel.text! + " min"
        
        let runmin = run.duration!.doubleValue / 60
        
        let rundist = run.distance!.doubleValue
        
        let pace = (round((runmin / rundist) * 100) / 100)
        
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
        paceLabel.text = paceLabel.text! + " min/mi"
        
        loadMap()
    }
    
    func mapRegion() -> MKCoordinateRegion {
        let initialLoc = run.locations!.firstObject as! Location
        
        var minLat = initialLoc.latitude.doubleValue
        var minLng = initialLoc.longitude.doubleValue
        var maxLat = minLat
        var maxLng = minLng
        
        let locations = run.locations!.array as! [Location]
        
        for location in locations {
            minLat = min(minLat, location.latitude.doubleValue)
            minLng = min(minLng, location.longitude.doubleValue)
            maxLat = max(maxLat, location.latitude.doubleValue)
            maxLng = max(maxLng, location.longitude.doubleValue)
        }
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat + maxLat)/2,
                longitude: (minLng + maxLng)/2),
            span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat)*1.1,
                longitudeDelta: (maxLng - minLng)*1.1))
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if !overlay.isKindOfClass(MulticolorPolylineSegment) {
            return MKOverlayRenderer()
        }
        
        let polyline = overlay as! MulticolorPolylineSegment
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = polyline.color
        renderer.lineWidth = 3
        return renderer
    }
    
    func polyline() -> MKPolyline {
        var coords = [CLLocationCoordinate2D]()
        
        let locations = run.locations!.array as! [Location]
        for location in locations {
            coords.append(CLLocationCoordinate2D(latitude: location.latitude.doubleValue,
                longitude: location.longitude.doubleValue))
        }
        
        return MKPolyline(coordinates: &coords, count: run.locations!.count)
    }
    
    func loadMap() {
        if run.locations!.count > 0 {
            mapView.delegate = self
            mapView.hidden = false
            
            // Set the map bounds
            mapView.region = mapRegion()
            
            // Make the line(s!) on the map
            let colorSegments = MulticolorPolylineSegment.colorSegments(forLocations: run.locations!.array as! [Location])
            mapView.addOverlays(colorSegments)
        } else {
            // No locations were found!
            mapView.hidden = true
            
            UIAlertView(title: "Error",
                message: "Sorry, this run has no locations saved",
                delegate:nil,
                cancelButtonTitle: "OK").show()
        }
    }
    
}

extension pastRunDetailViewController: UIActionSheetDelegate {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        //save
        if buttonIndex == 1 {
            if Reachability.isConnectedToNetwork() == true {
                let username = "admin"
                let password = "Catfish99"
                let loginString = NSString(format: "%@:%@", username, password)
                let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
                let base64LoginString = loginData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                let URL: NSURL = NSURL(string: "http://smrs.zachal.com/runs.action")!
                let request:NSMutableURLRequest = NSMutableURLRequest(URL:URL)
                request.HTTPBody = postData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                request.HTTPMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
                    {
                        (response, data, error) in
                        
                        let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        if (responseString?.length > 6) {
                            
                            let chars = responseString?.substringToIndex(6)
                            if (chars?.rangeOfString("Valid") != nil) {
                            
                                let alertController = UIAlertController(title: "Success", message:
                                    "Run successfully uploaded to server", preferredStyle: UIAlertControllerStyle.Alert)
                                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                            
                                self.presentViewController(alertController, animated: true, completion: nil)
                            
                            }else{
                            
                                let alertController = UIAlertController(title: "Error", message:
                                    "An error ocurred uploading the run to the server. please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                            
                                self.presentViewController(alertController, animated: true, completion: nil)
                            
                            }
                        }else{
                        
                            let alertController = UIAlertController(title: "Error", message:
                                "An error ocurred uploading the run to the server. please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                        
                            self.presentViewController(alertController, animated: true, completion: nil)

                    
                        }
                    
                
                    
                }

            }else{
            
                let alertController = UIAlertController(title: "Error", message:
                    "No internet connection.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
        }
    }
}

// MARK: - MKMapViewDelegate
extension pastRunDetailViewController: MKMapViewDelegate {
}
