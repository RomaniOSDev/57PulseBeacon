//
//  ContentView.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import SwiftUI
import Combine


struct ContentView: View {
    @AppStorage("currentBeaconId") private var currentBeaconIdString: String?
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var libraryViewModel = BeaconLibraryViewModel()
    @State private var showSetup = false
    @State private var showLibrary = false
    
    private var currentBeacon: Beacon? {
        get {
            guard let idString = currentBeaconIdString,
                  let id = UUID(uuidString: idString) else {
                return nil
            }
            return libraryViewModel.getBeacon(by: id)
        }
    }
    
    private func setCurrentBeacon(_ beacon: Beacon?) {
        if let beacon = beacon {
            currentBeaconIdString = beacon.id.uuidString
            // Ensure beacon is in library
            if libraryViewModel.getBeacon(by: beacon.id) == nil {
                libraryViewModel.addBeacon(beacon)
            }
        } else {
            currentBeaconIdString = nil
        }
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if !hasCompletedOnboarding {
                OnboardingView()
            } else if let beacon = currentBeacon {
                ActiveBeaconView(viewModel: ActiveBeaconViewModel(beacon: beacon), currentBeacon: Binding(
                    get: { currentBeacon },
                    set: { setCurrentBeacon($0) }
                ))
            } else {
                HomeView(selectedBeacon: Binding(
                    get: { currentBeacon },
                    set: { setCurrentBeacon($0) }
                ))
            }
        }
        .sheet(isPresented: $showSetup) {
            BeaconSetupView(beacon: Binding(
                get: { currentBeacon },
                set: { newBeacon in
                    if let newBeacon = newBeacon {
                        libraryViewModel.addBeacon(newBeacon)
                        setCurrentBeacon(newBeacon)
                    }
                    showSetup = false
                }
            ))
        }
        .sheet(isPresented: $showLibrary) {
            BeaconLibraryView(selectedBeacon: Binding(
                get: { currentBeacon },
                set: { setCurrentBeacon($0) }
            ))
        }
        .onAppear {
            libraryViewModel.loadBeacons()
        }
    }
}

#Preview {
    ContentView()
}
