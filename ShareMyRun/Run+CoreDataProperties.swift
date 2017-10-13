//
//  Run+CoreDataProperties.swift
//  ShareMyRun
//
//  Created by Zachary Tipnis on 12/8/15.
//  Copyright © 2015 Zachal. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Run {

    @NSManaged var distance: NSNumber?
    @NSManaged var duration: NSNumber?
    @NSManaged var timestamp: NSDate?
    @NSManaged var workout: NSObject?
    @NSManaged var locations: NSOrderedSet?

}
