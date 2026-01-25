//
//  BeaconLibraryView.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import SwiftUI
import Combine

struct BeaconLibraryView: View {
    @StateObject private var viewModel = BeaconLibraryViewModel()
    @Binding var selectedBeacon: Beacon?
    @Environment(\.dismiss) var dismiss
    @State private var showSetup = false
    @State private var editingBeacon: Beacon?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                if viewModel.beacons.isEmpty {
                    VStack(spacing: 20) {
                        Text("No Beacons")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Create your first beacon to start monitoring")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    List {
                        ForEach(viewModel.beacons) { beacon in
                            BeaconRow(beacon: beacon)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedBeacon = beacon
                                    dismiss()
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        viewModel.deleteBeacon(beacon)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        editingBeacon = beacon
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Beacon Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSetup = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showSetup) {
                BeaconSetupView(
                    beacon: Binding(
                        get: { editingBeacon },
                        set: { newBeacon in
                            if let newBeacon = newBeacon {
                                if editingBeacon != nil {
                                    viewModel.updateBeacon(newBeacon)
                                } else {
                                    viewModel.addBeacon(newBeacon)
                                }
                                selectedBeacon = newBeacon
                            }
                            editingBeacon = nil
                            showSetup = false
                        }
                    )
                )
            }
            .onChange(of: editingBeacon) { newValue in
                if newValue != nil {
                    showSetup = true
                }
            }
        }
    }
}

struct BeaconRow: View {
    let beacon: Beacon
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(beacon.metricName)
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                Text("Zone: \(String(format: "%.0f", beacon.minValue)) - \(String(format: "%.0f", beacon.maxValue))")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                if let critical = beacon.criticalThreshold {
                    Text("• Critical: \(String(format: "%.0f", critical))")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#FF3C00"))
                }
            }
        }
        .padding(.vertical, 4)
    }
}
