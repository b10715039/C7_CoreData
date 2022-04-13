//
//  Car+CoreDataProperties.swift
//  C7_CoreData
//
//  Created by mac12 on 2022/4/13.
//
//

import Foundation
import CoreData


extension Car {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Car> {
        return NSFetchRequest<Car>(entityName: "Car")
    }

    @NSManaged public var plate: String?
    @NSManaged public var belongto: UserData?

}

extension Car : Identifiable {

}
