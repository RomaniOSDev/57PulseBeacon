//
//  AchievementNotificationView.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import SwiftUI

struct AchievementNotificationView: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    @State private var useEnhanced = true
    
    var body: some View {
        if useEnhanced {
            EnhancedAchievementAnimation(achievement: achievement, onDismiss: onDismiss)
        } else {
            LegacyAchievementView(achievement: achievement, onDismiss: onDismiss)
        }
    }
}

struct LegacyAchievementView: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    @State private var animate = false
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [achievement.color.color, achievement.color.color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: achievement.color.color.opacity(0.5), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: achievement.iconName)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(animate ? 1.0 : 0.5)
                .rotationEffect(.degrees(animate ? 0 : -180))
                
                VStack(spacing: 8) {
                    Text("Achievement Unlocked!")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(achievement.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(achievement.color.color)
                    
                    Text(achievement.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 40)
            .offset(y: animate ? 0 : 200)
            .opacity(animate ? 1 : 0)
            
            Spacer()
        }
        .background(Color.black.opacity(0.3))
        .ignoresSafeArea()
        .onTapGesture {
            withAnimation {
                animate = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onDismiss()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animate = true
            }
            
            // Auto dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    animate = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
                }
            }
        }
    }
}
