//
//  StatisticsViewModel.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import Foundation
import SwiftUI
import CoreData
import Combine

class StatisticsViewModel: ObservableObject {
    @Published var readings: [BeaconReading] = []
    let beacon: Beacon
    
    private let persistenceController = PersistenceController.shared
    
    init(beacon: Beacon) {
        self.beacon = beacon
        loadReadings()
    }
    
    func loadReadings() {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<BeaconReadingEntity> = BeaconReadingEntity.fetchRequest()
        request.predicate = NSPredicate(format: "beaconId == %@", beacon.id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BeaconReadingEntity.timestamp, ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            readings = entities.map { $0.toBeaconReading() }
        } catch {
            print("Failed to load readings: \(error)")
        }
    }
    
    // Average value
    var averageValue: Double {
        guard !readings.isEmpty else { return 0 }
        return readings.map { $0.value }.reduce(0, +) / Double(readings.count)
    }
    
    // Percentage in zone
    var inZonePercentage: Double {
        guard !readings.isEmpty else { return 0 }
        let inZoneCount = readings.filter { beacon.status(for: $0.value) == .inZone }.count
        return Double(inZoneCount) / Double(readings.count) * 100
    }
    
    // Min and Max values
    var minValue: Double {
        readings.map { $0.value }.min() ?? 0
    }
    
    var maxValue: Double {
        readings.map { $0.value }.max() ?? 0
    }
    
    // Trend (improving/worsening)
    var trend: Trend {
        guard readings.count >= 2 else { return .stable }
        
        let recentCount = min(10, readings.count)
        let recentReadings = Array(readings.suffix(recentCount))
        let olderCount = min(10, readings.count - recentCount)
        
        guard olderCount > 0 else { return .stable }
        
        let olderReadings = Array(readings.prefix(olderCount))
        let recentAvg = recentReadings.map { $0.value }.reduce(0, +) / Double(recentReadings.count)
        let olderAvg = olderReadings.map { $0.value }.reduce(0, +) / Double(olderReadings.count)
        
        let diff = recentAvg - olderAvg
        let threshold = (beacon.maxValue - beacon.minValue) * 0.1
        
        if diff > threshold {
            return .improving
        } else if diff < -threshold {
            return .worsening
        }
        return .stable
    }
    
    // Readings count
    var totalReadings: Int {
        readings.count
    }
    
    // Last 24 hours count
    var last24HoursCount: Int {
        let dayAgo = Date().addingTimeInterval(-24 * 60 * 60)
        return readings.filter { $0.timestamp >= dayAgo }.count
    }
    
    // Last 7 days count
    var last7DaysCount: Int {
        let weekAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        return readings.filter { $0.timestamp >= weekAgo }.count
    }
}

enum Trend {
    case improving
    case stable
    case worsening
    
    var description: String {
        switch self {
        case .improving:
            return "Improving"
        case .stable:
            return "Stable"
        case .worsening:
            return "Worsening"
        }
    }
    
    var color: Color {
        switch self {
        case .improving:
            return .green
        case .stable:
            return .gray
        case .worsening:
            return Color(hex: "#FF3C00")
        }
    }
    
    var icon: String {
        switch self {
        case .improving:
            return "arrow.up"
        case .stable:
            return "arrow.right"
        case .worsening:
            return "arrow.down"
        }
    }
}
