//
//  Beacon.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import Foundation

enum BeaconStatus {
    case inZone
    case outOfZone
    case critical
}

struct Beacon: Identifiable, Codable, Equatable {
    let id: UUID
    var metricName: String
    var minValue: Double
    var maxValue: Double
    var criticalThreshold: Double?
    
    init(id: UUID = UUID(), metricName: String, minValue: Double, maxValue: Double, criticalThreshold: Double? = nil) {
        self.id = id
        self.metricName = metricName
        self.minValue = minValue
        self.maxValue = maxValue
        self.criticalThreshold = criticalThreshold
    }
    
    func status(for value: Double) -> BeaconStatus {
        if let critical = criticalThreshold, value >= critical {
            return .critical
        }
        if value >= minValue && value <= maxValue {
            return .inZone
        }
        return .outOfZone
    }
}

struct BeaconReading: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let value: Double
    
    init(id: UUID = UUID(), timestamp: Date = Date(), value: Double) {
        self.id = id
        self.timestamp = timestamp
        self.value = value
    }
}
