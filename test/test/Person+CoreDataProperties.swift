//
//  Person+CoreDataProperties.swift
//  test
//
//  Created by CHENWEI CHIH on 6/18/16.
//  Copyright © 2016 HealthCare.inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Person {

    @NSManaged var firstname: String?
    @NSManaged var lastname: String?
    @NSManaged var email: String?
    @NSManaged var password: String?
    @NSManaged var image: NSData?

}
