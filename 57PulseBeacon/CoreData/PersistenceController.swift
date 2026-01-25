//
//  PersistenceController.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import CoreData
import Foundation

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        // Create model programmatically
        let model = NSManagedObjectModel()
        
        // BeaconReadingEntity
        let readingEntity = NSEntityDescription()
        readingEntity.name = "BeaconReadingEntity"
        readingEntity.managedObjectClassName = "BeaconReadingEntity"
        
        // Attributes
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = true
        
        let timestampAttribute = NSAttributeDescription()
        timestampAttribute.name = "timestamp"
        timestampAttribute.attributeType = .dateAttributeType
        timestampAttribute.isOptional = true
        
        let valueAttribute = NSAttributeDescription()
        valueAttribute.name = "value"
        valueAttribute.attributeType = .doubleAttributeType
        valueAttribute.isOptional = false
        
        let beaconIdAttribute = NSAttributeDescription()
        beaconIdAttribute.name = "beaconId"
        beaconIdAttribute.attributeType = .UUIDAttributeType
        beaconIdAttribute.isOptional = true
        
        readingEntity.properties = [idAttribute, timestampAttribute, valueAttribute, beaconIdAttribute]
        
        model.entities = [readingEntity]
        
        container = NSPersistentContainer(name: "BeaconDataModel", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("BeaconDataModel.sqlite")
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
