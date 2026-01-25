//
//  BeaconSetupViewModel.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import Foundation
import Combine
import SwiftUI

class BeaconSetupViewModel: ObservableObject {
    @Published var selectedMetric: String = ""
    @Published var customMetric: String = ""
    @Published var minValue: String = ""
    @Published var maxValue: String = ""
    @Published var criticalThreshold: String = ""
    @Published var showCustomMetric: Bool = false
    
    let predefinedMetrics = ["Heart Rate", "Weight", "Pace (min/km)", "RPE (1-10)", "Custom"]
    
    var metricName: String {
        if selectedMetric == "Custom" {
            return customMetric
        }
        return selectedMetric
    }
    
    func createBeacon(id: UUID? = nil) -> Beacon? {
        guard !metricName.isEmpty,
              let min = Double(minValue),
              let max = Double(maxValue),
              min < max else {
            return nil
        }
        
        let critical: Double? = criticalThreshold.isEmpty ? nil : Double(criticalThreshold)
        
        return Beacon(
            id: id ?? UUID(),
            metricName: metricName,
            minValue: min,
            maxValue: max,
            criticalThreshold: critical
        )
    }
}
