//
//  ActiveBeaconViewModel.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import Foundation
import SwiftUI
import CoreData
import Combine

class ActiveBeaconViewModel: ObservableObject {
    @Published var currentValue: String = ""
    @Published var lastValue: Double?
    @Published var currentStatus: BeaconStatus = .inZone
    @Published var isPulsating: Bool = false
    @Published var readings: [BeaconReading] = []
    
    let beacon: Beacon
    private let persistenceController = PersistenceController.shared
    
    init(beacon: Beacon) {
        self.beacon = beacon
        loadReadings()
        // Set last value from most recent reading
        if let lastReading = readings.last {
            lastValue = lastReading.value
            currentValue = String(format: "%.1f", lastReading.value)
            currentStatus = beacon.status(for: lastReading.value)
            if currentStatus == .critical {
                isPulsating = true
            }
        }
    }
    
    func updateValue(_ text: String) {
        currentValue = text
        
        if let value = Double(text) {
            lastValue = value
            currentStatus = beacon.status(for: value)
            
            // Add reading to history
            let reading = BeaconReading(value: value)
            readings.append(reading)
            
            // Save to CoreData
            saveReading(reading)
            
            // Add XP for recording
            let gameManager = GameProgressManager()
            gameManager.addXP(5)
            
            // Update challenges
            updateChallenges(gameManager: gameManager)
            
            // Trigger pulsation animation for critical status
            if currentStatus == .critical {
                startPulsation()
            } else {
                stopPulsation()
            }
        } else {
            currentStatus = .inZone
            stopPulsation()
        }
    }
    
    private func saveReading(_ reading: BeaconReading) {
        let context = persistenceController.container.viewContext
        let entity = BeaconReadingEntity(context: context, reading: reading, beaconId: beacon.id)
        persistenceController.save()
        
        // Check achievements
        let achievementManager = AchievementManager()
        achievementManager.checkAchievements(for: beacon)
    }
    
    private func loadReadings() {
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
    
    private func startPulsation() {
        guard !isPulsating else { return }
        isPulsating = true
    }
    
    private func stopPulsation() {
        isPulsating = false
    }
    
    var valueDisplay: String {
        if let value = lastValue {
            return String(format: "%.1f", value)
        }
        return ""
    }
    
    var zoneIndicator: String {
        let min = String(format: "%.0f", beacon.minValue)
        let max = String(format: "%.0f", beacon.maxValue)
        if let current = lastValue {
            let currentStr = String(format: "%.0f", current)
            return "\(min) ← [\(currentStr)] → \(max)"
        }
        return "\(min) ← [ ] → \(max)"
    }
    
    private func updateChallenges(gameManager: GameProgressManager) {
        // Update reading count challenge
        if let challenge = gameManager.dailyChallenges.first(where: { $0.title.contains("Record") && $0.title.contains("Readings") }) {
            gameManager.updateChallengeProgress(challengeId: challenge.id, value: challenge.currentValue + 1)
        }
        
        // Update zone challenge
        if let value = lastValue {
            let status = beacon.status(for: value)
            if status == .inZone {
                // Calculate in-zone percentage
                let inZoneCount = readings.filter { beacon.status(for: $0.value) == .inZone }.count
                let percentage = Double(inZoneCount) / Double(readings.count) * 100
                if let challenge = gameManager.dailyChallenges.first(where: { $0.title.contains("Zone") }) {
                    gameManager.updateChallengeProgress(challengeId: challenge.id, value: Int(percentage))
                }
            }
        }
        
        // Check early bird challenge
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 9 {
            if let challenge = gameManager.dailyChallenges.first(where: { $0.title.contains("Early") }) {
                gameManager.updateChallengeProgress(challengeId: challenge.id, value: 1)
            }
        }
    }
}
