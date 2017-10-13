//
//  JSONCreator.swift
//  ShareMyRun
//
//  Created by Zachary Tipnis on 12/29/15.
//  Copyright © 2015 Zachal. All rights reserved.
//

import Foundation


    func createJSON(user:String,run:Run) -> String{
        
        var json = ""
        json = ""
        json = json + "{"
        json = json + "\"user\": \" \(user)\", "
        json = json + "\"distance\": \" \(String(run.distance!.doubleValue))\", "
        json = json + "\"duration\": \" \(String(run.duration!.doubleValue))\", "
        let runmin = run.duration!.doubleValue / 60
        let rundist = run.distance!.doubleValue
        let pace = (round((runmin / rundist) * 100) / 100)
        json = json + "\"pace\": \" \(String(pace))\", "
        json = json + "\"locations\": [ {"
        let locations = run.locations!.array as! [Location]
        
        let location = locations[0]
        let long = location.longitude
        let lat = location.latitude
        let timestamp:Double = (location.timestamp.timeIntervalSince1970)
        
        json = json +  "\"latitude\": \" \(String(lat))\", "
        json = json +  "\"longitude\": \" \(String(long))\", "
        json = json +  "\"timestamp\": \" \(String(timestamp))\" "
        json = json + " }"
        for var n = 1; n<locations.count; ++n {
            
            json = json + ", {"
            let location = locations[n]
            let long = location.longitude
            let lat = location.latitude
            let timestamp:Double = (location.timestamp.timeIntervalSince1970)
            json = json +  "\"latitude\": \" \(String(lat))\", "
            json = json +  "\"longitude\": \" \(String(long))\", "
            json = json +  "\"timestamp\": \" \(String(timestamp))\" "
            json = json + " }"
            
        }
        json = json + "],"
        
        let runTimestamp:Double = (run.timestamp?.timeIntervalSince1970)!
        json = json + " \"timestamp\": \" \(String(runTimestamp))\", "
        json = json + " \"uploaded\": \" \(String(NSDate().timeIntervalSince1970))\" "
        
        json = json + " }"
        return json
        
    }