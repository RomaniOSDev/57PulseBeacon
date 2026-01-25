//
//  HomeView.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var libraryViewModel = BeaconLibraryViewModel()
    @StateObject private var achievementManager = AchievementManager()
    @State private var showSetup = false
    @State private var showLibrary = false
    @State private var showAchievements = false
    @State private var showTemplates = false
    @State private var showGamification = false
    @State private var showSettings = false
    @State private var animateCards = false
    @Binding var selectedBeacon: Beacon?
    
    var body: some View {
        ZStack {
            // Animated background with gradient
            AnimatedBackground()
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header Section
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.gray)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(Color.gray.opacity(0.1))
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    VStack(spacing: 12) {
                        // Logo/Icon
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#FF3C00").opacity(0.2), Color(hex: "#FF3C00").opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .shadow(color: Color(hex: "#FF3C00").opacity(0.3), radius: 20, x: 0, y: 10)
                            
                            Image(systemName: "waveform.path.ecg")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(Color(hex: "#FF3C00"))
                        }
                        .padding(.top, 40)
                        .opacity(animateCards ? 1 : 0)
                        .scaleEffect(animateCards ? 1 : 0.8)
                        
                        Text("Pulse Beacon")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.primary, Color.primary.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : -20)
                        
                        Text("Monitor your metrics with precision")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : -20)
                    }
                    .padding(.bottom, 40)
                    
                    // Quick Stats
                    if !libraryViewModel.beacons.isEmpty {
                        HStack(spacing: 16) {
                            StatIconCard(
                                icon: "waveform.path.ecg",
                                value: "\(libraryViewModel.beacons.count)",
                                label: "Beacons",
                                color: .blue,
                                delay: 0.1
                            )
                            
                            StatIconCard(
                                icon: "trophy.fill",
                                value: "\(achievementManager.unlockedCount)",
                                label: "Achievements",
                                color: Color(hex: "#FF3C00"),
                                delay: 0.2
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                    
                    // Main Action Cards
                    VStack(spacing: 16) {
                        // Create Beacon Card - Hero Card
                        HeroActionCard(
                            icon: "plus.circle.fill",
                            title: "Create Beacon",
                            subtitle: "Start monitoring a new metric",
                            gradient: LinearGradient(
                                colors: [Color(hex: "#FF3C00"), Color(hex: "#FF6B3D")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            delay: 0.3,
                            action: {
                                showSetup = true
                            }
                        )
                        
                        // Templates Card
                        ModernActionCard(
                            icon: "square.grid.2x2.fill",
                            title: "Use Template",
                            subtitle: "Quick setup for sports",
                            color: .purple,
                            delay: 0.35,
                            action: {
                                showTemplates = true
                            }
                        )
                        
                        // Library Card
                        if !libraryViewModel.beacons.isEmpty {
                            ModernActionCard(
                                icon: "square.grid.2x2.fill",
                                title: "Beacon Library",
                                subtitle: "\(libraryViewModel.beacons.count) beacons available",
                                color: .blue,
                                delay: 0.4,
                                action: {
                                    showLibrary = true
                                }
                            )
                        }
                        
                        // Achievements Card
                        ModernActionCard(
                            icon: "trophy.fill",
                            title: "Achievements",
                            subtitle: "\(achievementManager.unlockedCount)/\(achievementManager.totalCount) unlocked",
                            color: Color(red: 1.0, green: 0.84, blue: 0.0),
                            delay: 0.5,
                            action: {
                                showAchievements = true
                            }
                        )
                        
                        // Gamification Card
                        ModernActionCard(
                            icon: "gamecontroller.fill",
                            title: "Progress",
                            subtitle: "Level, challenges & badges",
                            color: .green,
                            delay: 0.55,
                            action: {
                                showGamification = true
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                    
                    // Recent Beacons
                    if !libraryViewModel.beacons.isEmpty {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text("Recent Beacons")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(Array(libraryViewModel.beacons.prefix(5).enumerated()), id: \.element.id) { index, beacon in
                                        BeaconQuickCard(beacon: beacon, delay: Double(index) * 0.1) {
                                            selectedBeacon = beacon
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .sheet(isPresented: $showSetup) {
            BeaconSetupView(beacon: Binding(
                get: { nil },
                set: { newBeacon in
                    if let newBeacon = newBeacon {
                        libraryViewModel.addBeacon(newBeacon)
                        selectedBeacon = newBeacon
                    }
                    showSetup = false
                }
            ))
        }
        .sheet(isPresented: $showLibrary) {
            BeaconLibraryView(selectedBeacon: $selectedBeacon)
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView()
        }
        .sheet(isPresented: $showTemplates) {
            TemplateSelectionView(selectedBeacon: $selectedBeacon)
        }
        .sheet(isPresented: $showGamification) {
            GamificationView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            libraryViewModel.loadBeacons()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateCards = true
            }
        }
    }
}

// Animated Background
struct AnimatedBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color.white,
                    Color.gray.opacity(0.03),
                    Color.white
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated circles
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#FF3C00").opacity(0.1), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: animate ? -100 : 100, y: -200)
                .blur(radius: 60)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.blue.opacity(0.08), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 350, height: 350)
                .offset(x: animate ? 150 : -150, y: 300)
                .blur(radius: 50)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

struct StatIconCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let delay: Double
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color.opacity(0.3), color.opacity(0.0)],
                            center: .center,
                            startRadius: 20,
                            endRadius: 40
                        )
                    )
                    .frame(width: 80, height: 80)
                    .blur(radius: 10)
                
                // Main circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.25), color.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(color: color.opacity(0.4), radius: 15, x: 0, y: 8)
                
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.06), radius: 20, x: 0, y: 10)
        )
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                appear = true
            }
        }
    }
}

struct HeroActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradient: LinearGradient
    let delay: Double
    let action: () -> Void
    @State private var appear = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // 3D Icon
                ZStack {
                    // Multiple shadow layers for depth
                    Circle()
                        .fill(Color.black.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .offset(x: 0, y: 8)
                        .blur(radius: 12)
                    
                    Circle()
                        .fill(Color.black.opacity(0.1))
                        .frame(width: 80, height: 80)
                        .offset(x: 0, y: 4)
                        .blur(radius: 8)
                    
                    // Main circle with gradient
                    Circle()
                        .fill(gradient)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.4), lineWidth: 3)
                        )
                        .shadow(color: Color(hex: "#FF3C00").opacity(0.5), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: icon)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(isPressed ? 0.92 : 1.0)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(gradient)
                    .shadow(color: Color(hex: "#FF3C00").opacity(0.4), radius: 25, x: 0, y: 15)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 30)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(delay)) {
                appear = true
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}

struct ModernActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let delay: Double
    let action: () -> Void
    @State private var appear = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // Icon with depth
                ZStack {
                    // Shadow
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 70, height: 70)
                        .offset(x: 0, y: 5)
                        .blur(radius: 10)
                    
                    // Main circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 2.5)
                        )
                        .shadow(color: color.opacity(0.4), radius: 15, x: 0, y: 8)
                    
                    Image(systemName: icon)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(isPressed ? 0.95 : 1.0)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.6))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                appear = true
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}

struct BeaconQuickCard: View {
    let beacon: Beacon
    let delay: Double
    let action: () -> Void
    @State private var appear = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.25), Color.blue.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 55, height: 55)
                            .overlay(
                                Circle()
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                            )
                            .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                }
                
                Text(beacon.metricName)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("\(String(format: "%.0f", beacon.minValue)) - \(String(format: "%.0f", beacon.maxValue))")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
            }
            .padding(18)
            .frame(width: 170)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .opacity(appear ? 1 : 0)
        .offset(x: appear ? 0 : 30)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay)) {
                appear = true
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}
