//
//  GameProgress.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import Foundation
import SwiftUI
import Combine

struct UserLevel: Codable {
    var currentLevel: Int
    var currentXP: Int
    var totalXP: Int
    
    var xpToNextLevel: Int {
        levelXPRequirement(currentLevel + 1) - currentXP
    }
    
    var progressToNextLevel: Double {
        guard currentLevel < UserLevel.maxLevel else { return 1.0 }
        let currentLevelXP = levelXPRequirement(currentLevel)
        let nextLevelXP = levelXPRequirement(currentLevel + 1)
        let progress = Double(currentXP - currentLevelXP) / Double(nextLevelXP - currentLevelXP)
        return min(1.0, max(0.0, progress))
    }
    
    func levelXPRequirement(_ level: Int) -> Int {
        // Exponential XP curve
        return Int(100 * pow(1.5, Double(level - 1)))
    }
    
    static let maxLevel = 50
}

struct DailyChallenge: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let targetValue: Int
    var currentValue: Int
    let xpReward: Int
    let iconName: String
    let color: ChallengeColor
    var isCompleted: Bool
    
    enum ChallengeColor: String, Codable {
        case red, blue, green, orange, purple
        
        var color: Color {
            switch self {
            case .red: return Color(hex: "#FF3C00")
            case .blue: return .blue
            case .green: return .green
            case .orange: return .orange
            case .purple: return .purple
            }
        }
    }
    
    var progress: Double {
        min(1.0, Double(currentValue) / Double(targetValue))
    }
}

struct Badge: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let iconName: String
    let rarity: BadgeRarity
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    enum BadgeRarity: String, Codable {
        case common, rare, epic, legendary
        
        var color: Color {
            switch self {
            case .common: return .gray
            case .rare: return .blue
            case .epic: return .purple
            case .legendary: return Color(red: 1.0, green: 0.84, blue: 0.0)
            }
        }
    }
}

class GameProgressManager: ObservableObject {
    @AppStorage("userLevel") private var levelData: Data?
    @AppStorage("dailyChallenges") private var challengesData: Data?
    @AppStorage("badges") private var badgesData: Data?
    
    @Published var level: UserLevel
    @Published var dailyChallenges: [DailyChallenge]
    @Published var badges: [Badge]
    
    init() {
        self.level = UserLevel(currentLevel: 1, currentXP: 0, totalXP: 0)
        self.dailyChallenges = []
        self.badges = []
        loadData()
        initializeIfNeeded()
    }
    
    private func loadData() {
        if let data = levelData,
           let decoded = try? JSONDecoder().decode(UserLevel.self, from: data) {
            level = decoded
        }
        
        if let data = challengesData,
           let decoded = try? JSONDecoder().decode([DailyChallenge].self, from: data) {
            dailyChallenges = decoded
        }
        
        if let data = badgesData,
           let decoded = try? JSONDecoder().decode([Badge].self, from: data) {
            badges = decoded
        }
    }
    
    private func saveData() {
        if let data = try? JSONEncoder().encode(level) {
            levelData = data
        }
        if let data = try? JSONEncoder().encode(dailyChallenges) {
            challengesData = data
        }
        if let data = try? JSONEncoder().encode(badges) {
            badgesData = data
        }
    }
    
    private func initializeIfNeeded() {
        if dailyChallenges.isEmpty {
            generateDailyChallenges()
        }
        if badges.isEmpty {
            initializeBadges()
        }
    }
    
    func addXP(_ amount: Int) {
        let oldLevel = level.currentLevel
        level.currentXP += amount
        level.totalXP += amount
        
        // Check level up
        while level.currentLevel < UserLevel.maxLevel && level.currentXP >= level.levelXPRequirement(level.currentLevel + 1) {
            level.currentLevel += 1
        }
        
        if level.currentLevel > oldLevel {
            // Level up!
            NotificationCenter.default.post(name: NSNotification.Name("LevelUp"), object: level.currentLevel)
        }
        
        saveData()
    }
    
    func generateDailyChallenges() {
        dailyChallenges = [
            DailyChallenge(
                id: UUID(),
                title: "Record 5 Readings",
                description: "Make 5 measurements today",
                targetValue: 5,
                currentValue: 0,
                xpReward: 50,
                iconName: "target",
                color: .blue,
                isCompleted: false
            ),
            DailyChallenge(
                id: UUID(),
                title: "Stay in Zone",
                description: "Keep 80% readings in zone",
                targetValue: 80,
                currentValue: 0,
                xpReward: 75,
                iconName: "checkmark.circle.fill",
                color: .green,
                isCompleted: false
            ),
            DailyChallenge(
                id: UUID(),
                title: "Early Bird",
                description: "Record before 9 AM",
                targetValue: 1,
                currentValue: 0,
                xpReward: 30,
                iconName: "sunrise.fill",
                color: .orange,
                isCompleted: false
            )
        ]
        saveData()
    }
    
    private func initializeBadges() {
        badges = [
            Badge(id: UUID(), name: "First Steps", description: "Complete your first challenge", iconName: "star.fill", rarity: .common, isUnlocked: false),
            Badge(id: UUID(), name: "Week Warrior", description: "Complete 7 daily challenges", iconName: "flame.fill", rarity: .rare, isUnlocked: false),
            Badge(id: UUID(), name: "Level 10", description: "Reach level 10", iconName: "10.circle.fill", rarity: .epic, isUnlocked: false),
            Badge(id: UUID(), name: "Perfect Week", description: "Complete all challenges for a week", iconName: "crown.fill", rarity: .legendary, isUnlocked: false)
        ]
        saveData()
    }
    
    func updateChallengeProgress(challengeId: UUID, value: Int) {
        if let index = dailyChallenges.firstIndex(where: { $0.id == challengeId }) {
            dailyChallenges[index].currentValue = value
            if !dailyChallenges[index].isCompleted && dailyChallenges[index].currentValue >= dailyChallenges[index].targetValue {
                dailyChallenges[index].isCompleted = true
                addXP(dailyChallenges[index].xpReward)
            }
            saveData()
        }
    }
    
    func unlockBadge(_ badgeId: UUID) {
        if let index = badges.firstIndex(where: { $0.id == badgeId }) {
            badges[index].isUnlocked = true
            badges[index].unlockedDate = Date()
            saveData()
        }
    }
}
