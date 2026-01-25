//
//  Achievement.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import Foundation
import SwiftUI

struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let color: AchievementColor
    let requirement: AchievementRequirement
    var isUnlocked: Bool
    var unlockedDate: Date?
    var progress: Double // 0.0 to 1.0
    
    enum AchievementColor: String, Codable, Equatable {
        case gold
        case silver
        case bronze
        case blue
        case green
        case red
        
        var color: Color {
            switch self {
            case .gold:
                return Color(red: 1.0, green: 0.84, blue: 0.0)
            case .silver:
                return Color(red: 0.75, green: 0.75, blue: 0.75)
            case .bronze:
                return Color(red: 0.8, green: 0.5, blue: 0.2)
            case .blue:
                return .blue
            case .green:
                return .green
            case .red:
                return Color(hex: "#FF3C00")
            }
        }
    }
    
    enum AchievementRequirement: Codable, Equatable {
        case totalReadings(count: Int)
        case inZonePercentage(percentage: Double)
        case consecutiveDays(days: Int)
        case perfectDay // All readings in zone for a day
        case milestone(value: Double)
        case streak(days: Int)
    }
}
