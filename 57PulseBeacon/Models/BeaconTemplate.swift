//
//  BeaconTemplate.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import Foundation
import SwiftUI

struct BeaconTemplate: Identifiable, Codable {
    let id: UUID
    let name: String
    let category: SportCategory
    let iconName: String
    let color: TemplateColor
    let metricName: String
    let minValue: Double
    let maxValue: Double
    let criticalThreshold: Double?
    let description: String
    
    enum SportCategory: String, Codable, CaseIterable {
        case running = "Running"
        case cycling = "Cycling"
        case weightlifting = "Weightlifting"
        case swimming = "Swimming"
        case general = "General Health"
        case cardio = "Cardio"
        
        var icon: String {
            switch self {
            case .running: return "figure.run"
            case .cycling: return "bicycle"
            case .weightlifting: return "dumbbell.fill"
            case .swimming: return "figure.pool.swim"
            case .general: return "heart.fill"
            case .cardio: return "heart.circle.fill"
            }
        }
    }
    
    enum TemplateColor: String, Codable {
        case red, blue, green, orange, purple, pink
        
        var color: Color {
            switch self {
            case .red: return Color(hex: "#FF3C00")
            case .blue: return .blue
            case .green: return .green
            case .orange: return .orange
            case .purple: return .purple
            case .pink: return .pink
            }
        }
    }
    
    func toBeacon() -> Beacon {
        Beacon(
            metricName: metricName,
            minValue: minValue,
            maxValue: maxValue,
            criticalThreshold: criticalThreshold
        )
    }
}

class BeaconTemplateManager {
    static let shared = BeaconTemplateManager()
    
    let templates: [BeaconTemplate] = [
        // Running
        BeaconTemplate(
            id: UUID(),
            name: "Running Pace",
            category: .running,
            iconName: "figure.run",
            color: .red,
            metricName: "Pace (min/km)",
            minValue: 4.0,
            maxValue: 6.0,
            criticalThreshold: 3.5,
            description: "Monitor your running pace per kilometer"
        ),
        BeaconTemplate(
            id: UUID(),
            name: "Running Heart Rate",
            category: .running,
            iconName: "heart.fill",
            color: .red,
            metricName: "Heart Rate (bpm)",
            minValue: 140,
            maxValue: 160,
            criticalThreshold: 190,
            description: "Target heart rate zone for running"
        ),
        
        // Cycling
        BeaconTemplate(
            id: UUID(),
            name: "Cycling Speed",
            category: .cycling,
            iconName: "bicycle",
            color: .blue,
            metricName: "Speed (km/h)",
            minValue: 20,
            maxValue: 30,
            criticalThreshold: 40,
            description: "Monitor cycling speed"
        ),
        BeaconTemplate(
            id: UUID(),
            name: "Cycling Power",
            category: .cycling,
            iconName: "bolt.fill",
            color: .blue,
            metricName: "Power (W)",
            minValue: 150,
            maxValue: 250,
            criticalThreshold: 350,
            description: "Cycling power output"
        ),
        
        // Weightlifting
        BeaconTemplate(
            id: UUID(),
            name: "Bench Press",
            category: .weightlifting,
            iconName: "dumbbell.fill",
            color: .orange,
            metricName: "Weight (kg)",
            minValue: 60,
            maxValue: 80,
            criticalThreshold: 100,
            description: "Bench press weight monitoring"
        ),
        BeaconTemplate(
            id: UUID(),
            name: "Squat Weight",
            category: .weightlifting,
            iconName: "dumbbell.fill",
            color: .orange,
            metricName: "Weight (kg)",
            minValue: 80,
            maxValue: 120,
            criticalThreshold: 150,
            description: "Squat weight monitoring"
        ),
        BeaconTemplate(
            id: UUID(),
            name: "RPE Scale",
            category: .weightlifting,
            iconName: "gauge",
            color: .orange,
            metricName: "RPE (1-10)",
            minValue: 6,
            maxValue: 8,
            criticalThreshold: 10,
            description: "Rate of Perceived Exertion"
        ),
        
        // Swimming
        BeaconTemplate(
            id: UUID(),
            name: "Swimming Pace",
            category: .swimming,
            iconName: "figure.pool.swim",
            color: .blue,
            metricName: "Pace (min/100m)",
            minValue: 1.5,
            maxValue: 2.0,
            criticalThreshold: 1.2,
            description: "Swimming pace per 100 meters"
        ),
        
        // General Health
        BeaconTemplate(
            id: UUID(),
            name: "Resting Heart Rate",
            category: .general,
            iconName: "heart.fill",
            color: .red,
            metricName: "Heart Rate (bpm)",
            minValue: 60,
            maxValue: 80,
            criticalThreshold: 100,
            description: "Resting heart rate monitoring"
        ),
        BeaconTemplate(
            id: UUID(),
            name: "Body Weight",
            category: .general,
            iconName: "scalemass",
            color: .green,
            metricName: "Weight (kg)",
            minValue: 70,
            maxValue: 80,
            criticalThreshold: nil,
            description: "Body weight tracking"
        ),
        BeaconTemplate(
            id: UUID(),
            name: "Blood Pressure",
            category: .general,
            iconName: "waveform.path.ecg",
            color: .red,
            metricName: "Systolic (mmHg)",
            minValue: 110,
            maxValue: 130,
            criticalThreshold: 140,
            description: "Systolic blood pressure"
        ),
        
        // Cardio
        BeaconTemplate(
            id: UUID(),
            name: "Cardio Zone",
            category: .cardio,
            iconName: "heart.circle.fill",
            color: .red,
            metricName: "Heart Rate (bpm)",
            minValue: 120,
            maxValue: 150,
            criticalThreshold: 180,
            description: "Cardio heart rate zone"
        )
    ]
    
    func templates(for category: BeaconTemplate.SportCategory) -> [BeaconTemplate] {
        templates.filter { $0.category == category }
    }
}
