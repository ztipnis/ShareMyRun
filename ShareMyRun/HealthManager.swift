//
//  HealthManager.swift
//  Zachal LLC
//
//  Created by Zachary Tipnis on 18/10/14.
//  Copyright (c) 2014 Zachal LLC. All rights reserved.
//

import Foundation
import HealthKit

class HealthManager {
  let healthKitStore:HKHealthStore = HKHealthStore()
  


  
  func readProfile() -> ( age:Int?,  biologicalsex:HKBiologicalSexObject?, bloodtype:HKBloodTypeObject?)
  {
    var error:NSError?
    var age:Int?

    // 1. Request birthday and calculate age
    do {
      let birthDay = try healthKitStore.dateOfBirth()
      let today = NSDate()
      _ = NSCalendar.currentCalendar()
      let differenceComponents = NSCalendar.currentCalendar().components(.Year, fromDate: birthDay, toDate: today, options: NSCalendarOptions(rawValue: 0) )
      age = differenceComponents.year
    } catch let error1 as NSError {
      error = error1
    }
    if error != nil {
      print("Error reading Birthday: \(error)")
    }

    // 2. Read biological sex
    var biologicalSex:HKBiologicalSexObject?
    do {
      biologicalSex = try healthKitStore.biologicalSex()
    } catch let error1 as NSError {
      error = error1
      biologicalSex = nil
    };
    if error != nil {
      print("Error reading Biological Sex: \(error)")
    }
    // 3. Read blood type
    var bloodType:HKBloodTypeObject?
    do {
      bloodType = try healthKitStore.bloodType()
    } catch let error1 as NSError {
      error = error1
      bloodType = nil
    };
    if error != nil {
      print("Error reading Blood Type: \(error)")
    }

    // 4. Return the information read in a tuple
    return (age, biologicalSex, bloodType)
  }
  
  func readMostRecentSample(sampleType:HKSampleType , completion: ((HKSample!, NSError!) -> Void)!)
  {

    // 1. Build the Predicate
    let past = NSDate.distantPast() 
    let now   = NSDate()
    let mostRecentPredicate = HKQuery.predicateForSamplesWithStartDate(past, endDate:now, options: .None)

    // 2. Build the sort descriptor to return the samples in descending order
    let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
    // 3. we want to limit the number of samples returned by the query to just 1 (the most recent)
    let limit = 1

    // 4. Build samples query
    let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: limit, sortDescriptors: [sortDescriptor])
      { (sampleQuery, results, error ) -> Void in

        if let _ = error {
          completion(nil,error)
          return;
        }

        // Get the first sample
        let mostRecentSample = results!.first as? HKQuantitySample

        // Execute the completion closure
        if completion != nil {
          completion(mostRecentSample,nil)
        }
    }
    // 5. Execute the Query
    self.healthKitStore.executeQuery(sampleQuery)
  }
  
  func saveBMISample(bmi:Double, date:NSDate ) {

    // 1. Create a BMI Sample
    let bmiType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)
    let bmiQuantity = HKQuantity(unit: HKUnit.countUnit(), doubleValue: bmi)
    let bmiSample = HKQuantitySample(type: bmiType!, quantity: bmiQuantity, startDate: date, endDate: date)

    // 2. Save the sample in the store
    healthKitStore.saveObject(bmiSample, withCompletion: { (success, error) -> Void in
      if( error != nil ) {
        print("Error saving BMI sample: \(error!.localizedDescription)")
      } else {
        print("BMI sample saved successfully!")
      }
    })
  }
  
}