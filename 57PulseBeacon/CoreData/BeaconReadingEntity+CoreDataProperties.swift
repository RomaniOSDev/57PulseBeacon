//
//  BeaconReadingEntity+CoreDataProperties.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import Foundation
import CoreData

extension BeaconReadingEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BeaconReadingEntity> {
        return NSFetchRequest<BeaconReadingEntity>(entityName: "BeaconReadingEntity")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var timestamp: Date?
    @NSManaged public var value: Double
    @NSManaged public var beaconId: UUID?
}

extension BeaconReadingEntity : Identifiable {
}
