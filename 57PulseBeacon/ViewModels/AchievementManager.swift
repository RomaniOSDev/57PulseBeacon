//
//  AchievementManager.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import Foundation
import SwiftUI
import CoreData
import Combine

class AchievementManager: ObservableObject {
    @AppStorage("achievements") private var achievementsData: Data?
    @Published var achievements: [Achievement] = []
    
    private let persistenceController = PersistenceController.shared
    
    init() {
        loadAchievements()
        if achievements.isEmpty {
            initializeDefaultAchievements()
        }
    }
    
    private func initializeDefaultAchievements() {
        achievements = [
            Achievement(
                id: "first_reading",
                title: "First Step",
                description: "Record your first reading",
                iconName: "star.fill",
                color: .bronze,
                requirement: .totalReadings(count: 1),
                isUnlocked: false,
                progress: 0.0
            ),
            Achievement(
                id: "ten_readings",
                title: "Getting Started",
                description: "Record 10 readings",
                iconName: "star.circle.fill",
                color: .silver,
                requirement: .totalReadings(count: 10),
                isUnlocked: false,
                progress: 0.0
            ),
            Achievement(
                id: "fifty_readings",
                title: "Dedicated",
                description: "Record 50 readings",
                iconName: "star.circle.fill",
                color: .gold,
                requirement: .totalReadings(count: 50),
                isUnlocked: false,
                progress: 0.0
            ),
            Achievement(
                id: "hundred_readings",
                title: "Century",
                description: "Record 100 readings",
                iconName: "star.fill",
                color: .gold,
                requirement: .totalReadings(count: 100),
                isUnlocked: false,
                progress: 0.0
            ),
            Achievement(
                id: "perfect_zone",
                title: "Perfect Zone",
                description: "100% readings in zone for a day",
                iconName: "checkmark.circle.fill",
                color: .green,
                requirement: .perfectDay,
                isUnlocked: false,
                progress: 0.0
            ),
            Achievement(
                id: "zone_master",
                title: "Zone Master",
                description: "90% of readings in zone",
                iconName: "target",
                color: .blue,
                requirement: .inZonePercentage(percentage: 90),
                isUnlocked: false,
                progress: 0.0
            ),
            Achievement(
                id: "week_streak",
                title: "Week Warrior",
                description: "7 days in a row",
                iconName: "flame.fill",
                color: .red,
                requirement: .streak(days: 7),
                isUnlocked: false,
                progress: 0.0
            ),
            Achievement(
                id: "month_streak",
                title: "Month Champion",
                description: "30 days in a row",
                iconName: "flame.fill",
                color: .red,
                requirement: .streak(days: 30),
                isUnlocked: false,
                progress: 0.0
            )
        ]
        saveAchievements()
    }
    
    func loadAchievements() {
        guard let data = achievementsData,
              let decoded = try? JSONDecoder().decode([Achievement].self, from: data) else {
            achievements = []
            return
        }
        achievements = decoded
    }
    
    func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievements) {
            achievementsData = data
        }
    }
    
    func checkAchievements(for beacon: Beacon) {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<BeaconReadingEntity> = BeaconReadingEntity.fetchRequest()
        request.predicate = NSPredicate(format: "beaconId == %@", beacon.id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BeaconReadingEntity.timestamp, ascending: true)]
        
        guard let entities = try? context.fetch(request) else { return }
        let readings = entities.map { $0.toBeaconReading() }
        
        var hasNewUnlocks = false
        
        for index in achievements.indices {
            var achievement = achievements[index]
            
            if achievement.isUnlocked {
                continue
            }
            
            let (isUnlocked, progress) = checkRequirement(achievement.requirement, readings: readings, beacon: beacon)
            
            if isUnlocked && !achievement.isUnlocked {
                achievement.isUnlocked = true
                achievement.unlockedDate = Date()
                achievement.progress = 1.0
                hasNewUnlocks = true
            } else {
                achievement.progress = progress
            }
            
            achievements[index] = achievement
        }
        
        if hasNewUnlocks {
            saveAchievements()
        }
    }
    
    private func checkRequirement(_ requirement: Achievement.AchievementRequirement, readings: [BeaconReading], beacon: Beacon) -> (Bool, Double) {
        switch requirement {
        case .totalReadings(let count):
            let current = readings.count
            return (current >= count, min(1.0, Double(current) / Double(count)))
            
        case .inZonePercentage(let percentage):
            guard !readings.isEmpty else { return (false, 0.0) }
            let inZoneCount = readings.filter { beacon.status(for: $0.value) == .inZone }.count
            let currentPercentage = Double(inZoneCount) / Double(readings.count) * 100
            return (currentPercentage >= percentage, min(1.0, currentPercentage / percentage))
            
        case .consecutiveDays(let days):
            let uniqueDays = Set(readings.map { Calendar.current.startOfDay(for: $0.timestamp) })
            let sortedDays = Array(uniqueDays).sorted()
            var consecutive = 1
            var maxConsecutive = 1
            
            for i in 1..<sortedDays.count {
                if let daysBetween = Calendar.current.dateComponents([.day], from: sortedDays[i-1], to: sortedDays[i]).day,
                   daysBetween == 1 {
                    consecutive += 1
                    maxConsecutive = max(maxConsecutive, consecutive)
                } else {
                    consecutive = 1
                }
            }
            
            return (maxConsecutive >= days, min(1.0, Double(maxConsecutive) / Double(days)))
            
        case .perfectDay:
            let today = Calendar.current.startOfDay(for: Date())
            let todayReadings = readings.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: today) }
            guard !todayReadings.isEmpty else { return (false, 0.0) }
            let allInZone = todayReadings.allSatisfy { beacon.status(for: $0.value) == .inZone }
            return (allInZone, allInZone ? 1.0 : 0.0)
            
        case .milestone(let value):
            guard let maxReading = readings.map({ $0.value }).max() else { return (false, 0.0) }
            return (maxReading >= value, min(1.0, maxReading / value))
            
        case .streak(let days):
            let uniqueDays = Set(readings.map { Calendar.current.startOfDay(for: $0.timestamp) })
            let sortedDays = Array(uniqueDays).sorted(by: >)
            var streak = 0
            var currentDate = Calendar.current.startOfDay(for: Date())
            
            for day in sortedDays {
                if Calendar.current.isDate(day, inSameDayAs: currentDate) || 
                   Calendar.current.isDate(day, inSameDayAs: currentDate.addingTimeInterval(-24*60*60)) {
                    if Calendar.current.isDate(day, inSameDayAs: currentDate.addingTimeInterval(-24*60*60)) {
                        currentDate = day
                    }
                    streak += 1
                } else {
                    break
                }
            }
            
            return (streak >= days, min(1.0, Double(streak) / Double(days)))
        }
    }
    
    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var totalCount: Int {
        achievements.count
    }
}
