//
//  BeaconReadingEntity+CoreDataClass.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import Foundation
import CoreData

@objc(BeaconReadingEntity)
public class BeaconReadingEntity: NSManagedObject {
    convenience init(context: NSManagedObjectContext, reading: BeaconReading, beaconId: UUID) {
        let entity = NSEntityDescription.entity(forEntityName: "BeaconReadingEntity", in: context)!
        self.init(entity: entity, insertInto: context)
        self.id = reading.id
        self.timestamp = reading.timestamp
        self.value = reading.value
        self.beaconId = beaconId
    }
    
    func toBeaconReading() -> BeaconReading {
        BeaconReading(id: id ?? UUID(), timestamp: timestamp ?? Date(), value: value)
    }
}
