//
//  AchievementsView.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import SwiftUI

struct AchievementsView: View {
    @StateObject private var achievementManager = AchievementManager()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Stats
                        VStack(spacing: 12) {
                            Text("\(achievementManager.unlockedCount)/\(achievementManager.totalCount)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Achievements Unlocked")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            // Progress Bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 8)
                                        .cornerRadius(4)
                                    
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "#FF3C00"), Color.orange],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(
                                            width: geometry.size.width * CGFloat(achievementManager.unlockedCount) / CGFloat(achievementManager.totalCount),
                                            height: 8
                                        )
                                        .cornerRadius(4)
                                }
                            }
                            .frame(height: 8)
                            .padding(.horizontal, 40)
                        }
                        .padding(.vertical, 20)
                        
                        // Achievements Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(achievementManager.achievements) { achievement in
                                AchievementCard(achievement: achievement)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Achievements")
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

struct AchievementCard: View {
    let achievement: Achievement
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Background circle with gradient
                Circle()
                    .fill(
                        achievement.isUnlocked ?
                        LinearGradient(
                            colors: [achievement.color.color.opacity(0.3), achievement.color.color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: achievement.isUnlocked ? achievement.color.color.opacity(0.3) : Color.clear, radius: 8)
                
                // Icon
                Image(systemName: achievement.iconName)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(achievement.isUnlocked ? achievement.color.color : .gray)
                    .scaleEffect(isAnimating && achievement.isUnlocked ? 1.1 : 1.0)
            }
            
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(achievement.isUnlocked ? .primary : .gray)
                    .multilineTextAlignment(.center)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Progress indicator
                if !achievement.isUnlocked && achievement.progress > 0 {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)
                                .cornerRadius(2)
                            
                            Rectangle()
                                .fill(achievement.color.color)
                                .frame(width: geometry.size.width * CGFloat(achievement.progress), height: 4)
                                .cornerRadius(2)
                        }
                    }
                    .frame(height: 4)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(achievement.isUnlocked ? achievement.color.color.opacity(0.05) : Color.gray.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(achievement.isUnlocked ? achievement.color.color.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            if achievement.isUnlocked {
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
