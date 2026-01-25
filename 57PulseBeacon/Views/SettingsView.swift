//
//  SettingsView.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                List {
                    Section {
                        SettingsRow(
                            icon: "star.fill",
                            iconColor: Color(red: 1.0, green: 0.84, blue: 0.0),
                            title: "Rate Us",
                            action: {
                                rateApp()
                            }
                        )
                    }
                    
                    Section("Legal") {
                        SettingsRow(
                            icon: "lock.shield.fill",
                            iconColor: .blue,
                            title: "Privacy Policy",
                            action: {
                                openPrivacyPolicy()
                            }
                        )
                        
                        SettingsRow(
                            icon: "doc.text.fill",
                            iconColor: .gray,
                            title: "Terms of Service",
                            action: {
                                openTermsOfService()
                            }
                        )
                    }
                    
                    Section("About") {
                        HStack {
                            Text("Version")
                                .foregroundColor(.primary)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.gray)
                        }
                        
                        SettingsRow(
                            icon: "info.circle.fill",
                            iconColor: .blue,
                            title: "About Pulse Beacon",
                            action: {
                                // Can add about screen if needed
                            }
                        )
                    }
                    
                    Section {
                        Button(action: {
                            hasCompletedOnboarding = false
                            dismiss()
                        }) {
                            HStack {
                                Spacer()
                                Text("Show Onboarding Again")
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Settings")
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
    
    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://www.termsfeed.com/live/c75a4a58-9078-4977-a25b-88068a580def") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTermsOfService() {
        if let url = URL(string: "https://www.termsfeed.com/live/ba8cfac5-0b55-416e-810c-872660d1e673") {
            UIApplication.shared.open(url)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
        }
    }
}
