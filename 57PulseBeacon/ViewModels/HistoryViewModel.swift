//
//  HistoryViewModel.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import Foundation
import SwiftUI
import CoreData
import Combine

class HistoryViewModel: ObservableObject {
    @Published var readings: [BeaconReading]
    @Published var scrollOffset: CGFloat = 0
    let beacon: Beacon
    
    private let padding: CGFloat = 40
    private let persistenceController = PersistenceController.shared
    
    init(beacon: Beacon) {
        self.beacon = beacon
        self.readings = []
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
    
    var minValue: Double {
        guard !readings.isEmpty else { return 0 }
        return readings.map { $0.value }.min() ?? 0
    }
    
    var maxValue: Double {
        guard !readings.isEmpty else { return 100 }
        return readings.map { $0.value }.max() ?? 100
    }
    
    var chartData: [(x: Double, y: Double, status: BeaconStatus)] {
        readings.enumerated().map { index, reading in
            (x: Double(index), y: reading.value, status: beacon.status(for: reading.value))
        }
    }
    
    func maxScrollOffset(for width: CGFloat) -> CGFloat {
        guard !readings.isEmpty else { return 0 }
        let chartWidth = width - padding * 2
        let pointSpacing = chartWidth / CGFloat(max(readings.count - 1, 1))
        let totalWidth = CGFloat(readings.count - 1) * pointSpacing
        return max(0, totalWidth - chartWidth)
    }
    
    func updateScrollOffset(_ newOffset: CGFloat, chartWidth: CGFloat) {
        let maxOffset = maxScrollOffset(for: chartWidth)
        scrollOffset = max(0, min(maxOffset, newOffset))
    }
    
    func getSegmentColor(for index: Int) -> Color {
        guard index < readings.count else { return .black }
        let reading = readings[index]
        let status = beacon.status(for: reading.value)
        
        switch status {
        case .inZone:
            return .black
        case .outOfZone, .critical:
            return Color(hex: "#FF3C00")
        }
    }
}
