//
//  nearbyRunDetailViewController.swift
//  ShareMyRun
//
//  Created by Zachary Tipnis on 12/7/15.
//  Copyright © 2015 Zachal. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import HealthKit

class nearbyRunDetailViewController : UIViewController {
    var run: RunUnmanaged!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var distance:Double!
    var duration:Double!
    var timestamp:NSDate!
    var locSet:NSOrderedSet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    func configureView() {
        
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
        let str = formatter.stringFromNumber(secMutable)
        print(str)
        timeLabel.text = timeLabel.text! + str!
        timeLabel.text = timeLabel.text! + " min"
        

        
        loadMap()
    }
    
    func mapRegion() -> MKCoordinateRegion {
        let initialLoc = run.locations!.firstObject as! LocationUnmanaged
        
        var minLat = initialLoc.latitude.doubleValue
        var minLng = initialLoc.longitude.doubleValue
        var maxLat = minLat
        var maxLng = minLng
        
        let locations = run.locations!.array as! [LocationUnmanaged]
        
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
        if !overlay.isKindOfClass(MulticolorPolylineSegmentUnmanaged) {
            return MKOverlayRenderer()
        }
        
        let polyline = overlay as! MulticolorPolylineSegmentUnmanaged
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
            let colorSegments = MulticolorPolylineSegmentUnmanaged.colorSegments(forLocations: run.locations!.array as! [LocationUnmanaged])
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



// MARK: - MKMapViewDelegate
extension nearbyRunDetailViewController: MKMapViewDelegate {
}
