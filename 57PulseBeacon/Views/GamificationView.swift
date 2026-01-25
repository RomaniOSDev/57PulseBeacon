//
//  GamificationView.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import SwiftUI

struct GamificationView: View {
    @StateObject private var gameManager = GameProgressManager()
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Tab selector
                    Picker("", selection: $selectedTab) {
                        Text("Level").tag(0)
                        Text("Challenges").tag(1)
                        Text("Badges").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        LevelView(gameManager: gameManager)
                            .tag(0)
                        
                        ChallengesView(gameManager: gameManager)
                            .tag(1)
                        
                        BadgesView(gameManager: gameManager)
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct LevelView: View {
    @ObservedObject var gameManager: GameProgressManager
    @State private var showLevelUp = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Level Display
                VStack(spacing: 20) {
                    ZStack {
                        // Background circle
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                            .frame(width: 200, height: 200)
                        
                        // Progress circle
                        Circle()
                            .trim(from: 0, to: gameManager.level.progressToNextLevel)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "#FF3C00"), Color.orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 8) {
                            Text("LEVEL")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .tracking(2)
                            
                            Text("\(gameManager.level.currentLevel)")
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            if gameManager.level.currentLevel < UserLevel.maxLevel {
                                Text("\(gameManager.level.xpToNextLevel) XP to next")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    // XP Stats
                    HStack(spacing: 40) {
                        VStack {
                            Text("\(gameManager.level.currentXP)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Current XP")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Text("\(gameManager.level.totalXP)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Total XP")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.top, 40)
                
                // XP Sources
                VStack(alignment: .leading, spacing: 16) {
                    Text("Earn XP")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    XPInfoRow(icon: "target", title: "Complete Challenge", xp: "+50-100 XP", color: .blue)
                    XPInfoRow(icon: "star.fill", title: "Unlock Achievement", xp: "+25 XP", color: .orange)
                    XPInfoRow(icon: "checkmark.circle.fill", title: "Record Reading", xp: "+5 XP", color: .green)
                }
            }
            .padding()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LevelUp"))) { notification in
            if let level = notification.object as? Int {
                showLevelUp = true
            }
        }
        .sheet(isPresented: $showLevelUp) {
            LevelUpView(level: gameManager.level.currentLevel)
        }
    }
}

struct XPInfoRow: View {
    let icon: String
    let title: String
    let xp: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 40)
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(xp)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
        .padding(.horizontal)
    }
}

struct ChallengesView: View {
    @ObservedObject var gameManager: GameProgressManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Daily Challenges")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                ForEach(gameManager.dailyChallenges) { challenge in
                    ChallengeCard(challenge: challenge)
                }
            }
            .padding()
        }
    }
}

struct ChallengeCard: View {
    let challenge: DailyChallenge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(challenge.color.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: challenge.iconName)
                        .font(.title3)
                        .foregroundColor(challenge.color.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.title)
                        .font(.headline)
                    
                    Text(challenge.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if challenge.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                } else {
                    Text("+\(challenge.xpReward) XP")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(challenge.color.color)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(challenge.color.color)
                        .frame(
                            width: geometry.size.width * CGFloat(challenge.progress),
                            height: 8
                        )
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("\(challenge.currentValue)/\(challenge.targetValue)")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text("\(Int(challenge.progress * 100))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(challenge.color.color)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(challenge.isCompleted ? challenge.color.color.opacity(0.1) : Color.gray.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(challenge.isCompleted ? challenge.color.color.opacity(0.3) : Color.clear, lineWidth: 2)
        )
    }
}

struct BadgesView: View {
    @ObservedObject var gameManager: GameProgressManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Badges")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(gameManager.badges) { badge in
                        BadgeCard(badge: badge)
                    }
                }
            }
            .padding()
        }
    }
}

struct BadgeCard: View {
    let badge: Badge
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        badge.isUnlocked ?
                        RadialGradient(
                            colors: [badge.rarity.color.opacity(0.3), badge.rarity.color.opacity(0.1)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 40
                        ) :
                        RadialGradient(
                            colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 40
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(badge.isUnlocked ? badge.rarity.color.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(color: badge.isUnlocked ? badge.rarity.color.opacity(0.3) : Color.clear, radius: 10)
                
                Image(systemName: badge.iconName)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(badge.isUnlocked ? badge.rarity.color : .gray)
                    .scaleEffect(isAnimating && badge.isUnlocked ? 1.1 : 1.0)
            }
            
            Text(badge.name)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(badge.isUnlocked ? .primary : .gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .onAppear {
            if badge.isUnlocked {
                withAnimation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
        }
    }
}

struct LevelUpView: View {
    let level: Int
    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = -180
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("LEVEL UP!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#FF3C00"))
                    .opacity(opacity)
                
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "#FF3C00"), Color.orange],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 150, height: 150)
                        .shadow(color: Color(hex: "#FF3C00").opacity(0.5), radius: 30)
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(rotation))
                    
                    Text("\(level)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(-rotation))
                }
                
                Text("Congratulations!")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scale = 1.0
                rotation = 0
                opacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                dismiss()
            }
        }
        .onTapGesture {
            dismiss()
        }
    }
}
