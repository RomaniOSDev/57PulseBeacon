//
//  ActiveBeaconView.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import SwiftUI
import Combine

struct ActiveBeaconView: View {
    @StateObject var viewModel: ActiveBeaconViewModel
    @StateObject private var achievementManager = AchievementManager()
    @State private var showHistory = false
    @State private var showSetup = false
    @State private var showLibrary = false
    @State private var showStatistics = false
    @State private var showAchievements = false
    @State private var showGamification = false
    @State private var showSettings = false
    @State private var showQuickInput = false
    @State private var showMiniChart = true
    @State private var pulsationOpacity: Double = 0.0
    @State private var showAchievementNotification = false
    @State private var newAchievement: Achievement?
    @Binding var currentBeacon: Beacon?
    
    var body: some View {
        ZStack {
            // Background with pulsation effect
            Color.white
                .overlay(
                    Color(hex: "#FF3C00")
                        .opacity(pulsationOpacity)
                )
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Zone indicator (top corner)
                HStack {
                    // Home button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            currentBeacon = nil
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Home")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.gray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.gray.opacity(0.12))
                        )
                    }
                    
                    Text(viewModel.zoneIndicator)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    HStack(spacing: 12) {
                        Button(action: {
                            showQuickInput = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                        
                        Button(action: {
                            showLibrary = true
                        }) {
                            Image(systemName: "square.grid.2x2")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                        
                        Button(action: {
                            showStatistics = true
                        }) {
                            Image(systemName: "chart.bar")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                        
                        Button(action: {
                            showHistory = true
                        }) {
                            Image(systemName: "clock")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                        
                        Button(action: {
                            showAchievements = true
                        }) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "trophy.fill")
                                    .font(.caption)
                                
                                if achievementManager.unlockedCount > 0 {
                                    Circle()
                                        .fill(Color(hex: "#FF3C00"))
                                        .frame(width: 6, height: 6)
                                        .offset(x: 4, y: -4)
                                }
                            }
                        }
                        .foregroundColor(.gray)
                        
                        Button(action: {
                            showGamification = true
                        }) {
                            Image(systemName: "gamecontroller.fill")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                        
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                Spacer()
                
                // Main input area
                VStack(spacing: 20) {
                    // Large value display
                    ZStack {
                        if viewModel.currentValue.isEmpty && viewModel.lastValue != nil {
                            Text(viewModel.valueDisplay)
                                .font(.system(size: 80, weight: .bold))
                                .foregroundColor(textColor)
                                .opacity(0.3)
                        }
                        TextField("", text: $viewModel.currentValue)
                            .font(.system(size: 80, weight: .bold))
                            .multilineTextAlignment(.center)
                            .keyboardType(.decimalPad)
                            .foregroundColor(textColor)
                            .onChange(of: viewModel.currentValue) { newValue in
                                viewModel.updateValue(newValue)
                            }
                    }
                    
                    // Metric name label
                    Text(viewModel.beacon.metricName)
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                // Mini chart
                if showMiniChart && !viewModel.readings.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Recent Activity")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                            Button(action: {
                                showMiniChart.toggle()
                            }) {
                                Image(systemName: showMiniChart ? "chevron.down" : "chevron.up")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                        
                        MiniChartView(
                            readings: Array(viewModel.readings.suffix(20)),
                            beacon: viewModel.beacon,
                            minY: viewModel.readings.map { $0.value }.min() ?? 0,
                            maxY: viewModel.readings.map { $0.value }.max() ?? 100
                        )
                        .frame(height: 80)
                        .padding(.horizontal)
                    }
                } else if !showMiniChart {
                    Button(action: {
                        showMiniChart = true
                    }) {
                        HStack {
                            Text("Show Chart")
                                .font(.caption)
                            Image(systemName: "chevron.up")
                                .font(.caption2)
                        }
                        .foregroundColor(.gray)
                    }
                    .padding()
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showHistory) {
            HistoryView(beacon: viewModel.beacon)
        }
        .sheet(isPresented: $showSetup) {
            BeaconSetupView(beacon: $currentBeacon)
        }
        .sheet(isPresented: $showLibrary) {
            BeaconLibraryView(selectedBeacon: $currentBeacon)
        }
        .sheet(isPresented: $showStatistics) {
            StatisticsView(beacon: viewModel.beacon)
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView()
        }
        .sheet(isPresented: $showGamification) {
            GamificationView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            achievementManager.checkAchievements(for: viewModel.beacon)
        }
        .onChange(of: viewModel.readings.count) { _ in
            let beforeCount = achievementManager.unlockedCount
            achievementManager.checkAchievements(for: viewModel.beacon)
            let afterCount = achievementManager.unlockedCount
            
            if afterCount > beforeCount {
                if let newAchievement = achievementManager.achievements.first(where: { $0.isUnlocked && $0.unlockedDate != nil && abs($0.unlockedDate!.timeIntervalSinceNow) < 2 }) {
                    self.newAchievement = newAchievement
                    showAchievementNotification = true
                }
            }
        }
        .overlay {
            if showAchievementNotification, let achievement = newAchievement {
                AchievementNotificationView(achievement: achievement) {
                    showAchievementNotification = false
                }
            }
        }
        .overlay {
            if showQuickInput {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showQuickInput = false
                        }
                    
                    QuickInputWidget(viewModel: viewModel, isPresented: $showQuickInput)
                        .padding(.horizontal, 40)
                }
            }
        }
        .onChange(of: viewModel.isPulsating) { isPulsating in
            if isPulsating {
                startPulsation()
            } else {
                stopPulsation()
            }
        }
        .onAppear {
            if viewModel.isPulsating {
                startPulsation()
            }
        }
    }
    
    private func startPulsation() {
        withAnimation(
            Animation.easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
        ) {
            pulsationOpacity = 0.3
        }
    }
    
    private func stopPulsation() {
        withAnimation(.easeOut(duration: 0.3)) {
            pulsationOpacity = 0.0
        }
    }
    
    private var textColor: Color {
        switch viewModel.currentStatus {
        case .inZone:
            return .black
        case .outOfZone, .critical:
            return Color(hex: "#FF3C00")
        }
    }
}
