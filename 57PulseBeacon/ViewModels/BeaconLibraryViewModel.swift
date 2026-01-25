//
//  BeaconLibraryViewModel.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import Foundation
import SwiftUI
import Combine

class BeaconLibraryViewModel: ObservableObject {
    @AppStorage("beaconLibrary") private var beaconLibraryData: Data?
    @Published var beacons: [Beacon] = []
    
    init() {
        loadBeacons()
    }
    
    func loadBeacons() {
        guard let data = beaconLibraryData,
              let decoded = try? JSONDecoder().decode([Beacon].self, from: data) else {
            beacons = []
            return
        }
        beacons = decoded
    }
    
    func saveBeacons() {
        if let data = try? JSONEncoder().encode(beacons) {
            beaconLibraryData = data
        }
    }
    
    func addBeacon(_ beacon: Beacon) {
        beacons.append(beacon)
        saveBeacons()
    }
    
    func updateBeacon(_ beacon: Beacon) {
        if let index = beacons.firstIndex(where: { $0.id == beacon.id }) {
            beacons[index] = beacon
            saveBeacons()
        }
    }
    
    func deleteBeacon(_ beacon: Beacon) {
        beacons.removeAll { $0.id == beacon.id }
        saveBeacons()
    }
    
    func getBeacon(by id: UUID) -> Beacon? {
        beacons.first { $0.id == id }
    }
}
