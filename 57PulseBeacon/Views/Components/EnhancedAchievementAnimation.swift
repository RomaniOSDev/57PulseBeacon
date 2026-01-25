//
//  EnhancedAchievementAnimation.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import SwiftUI

struct EnhancedAchievementAnimation: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    @State private var scale: CGFloat = 0.3
    @State private var rotation: Double = -180
    @State private var opacity: Double = 0
    @State private var sparkleScale: CGFloat = 0
    @State private var showParticles = false
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .opacity(opacity)
            
            // Main achievement card
            VStack(spacing: 24) {
                // Sparkle particles
                if showParticles {
                    ForEach(0..<12, id: \.self) { index in
                        Circle()
                            .fill(achievement.color.color)
                            .frame(width: 8, height: 8)
                            .offset(
                                x: cos(Double(index) * .pi / 6) * 100,
                                y: sin(Double(index) * .pi / 6) * 100
                            )
                            .opacity(1 - sparkleScale)
                            .scaleEffect(sparkleScale)
                    }
                }
                
                // Achievement icon with glow
                ZStack {
                    // Outer glow rings
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(
                                achievement.color.color.opacity(0.3 - Double(index) * 0.1),
                                lineWidth: 3
                            )
                            .frame(width: 120 + CGFloat(index * 20), height: 120 + CGFloat(index * 20))
                            .scaleEffect(scale + CGFloat(index) * 0.1)
                            .opacity(opacity)
                    }
                    
                    // Main circle with gradient
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    achievement.color.color,
                                    achievement.color.color.opacity(0.7),
                                    achievement.color.color.opacity(0.4)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: achievement.color.color.opacity(0.6), radius: 30, x: 0, y: 15)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.5), lineWidth: 4)
                        )
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(rotation))
                    
                    // Icon
                    Image(systemName: achievement.iconName)
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(-rotation))
                }
                
                // Text content
                VStack(spacing: 12) {
                    Text("ACHIEVEMENT UNLOCKED!")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(achievement.color.color)
                        .tracking(2)
                        .opacity(opacity)
                    
                    Text(achievement.title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .opacity(opacity)
                        .scaleEffect(scale)
                    
                    Text(achievement.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .opacity(opacity)
                }
                .padding(.horizontal, 40)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.3), radius: 30, x: 0, y: 15)
            )
            .padding(.horizontal, 40)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onTapGesture {
            dismissAnimation()
        }
        .onAppear {
            startAnimation()
            
            // Auto dismiss after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                dismissAnimation()
            }
        }
    }
    
    private func startAnimation() {
        // Phase 1: Scale and rotate in
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            scale = 1.0
            rotation = 0
            opacity = 1.0
        }
        
        // Phase 2: Sparkles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showParticles = true
            withAnimation(.easeOut(duration: 1.0)) {
                sparkleScale = 1.5
            }
        }
        
        // Phase 3: Pulse effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.3).repeatCount(3, autoreverses: true)) {
                scale = 1.05
            }
        }
    }
    
    private func dismissAnimation() {
        withAnimation(.easeIn(duration: 0.3)) {
            scale = 0.8
            opacity = 0
            sparkleScale = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}
