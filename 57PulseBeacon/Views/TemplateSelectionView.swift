//
//  TemplateSelectionView.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import SwiftUI

struct TemplateSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedBeacon: Beacon?
    @State private var selectedCategory: BeaconTemplate.SportCategory? = nil
    
    let templateManager = BeaconTemplateManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Category Selection
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                CategoryButton(
                                    category: nil,
                                    title: "All",
                                    icon: "square.grid.2x2",
                                    isSelected: selectedCategory == nil
                                ) {
                                    selectedCategory = nil
                                }
                                
                                ForEach(BeaconTemplate.SportCategory.allCases, id: \.self) { category in
                                    CategoryButton(
                                        category: category,
                                        title: category.rawValue,
                                        icon: category.icon,
                                        isSelected: selectedCategory == category
                                    ) {
                                        selectedCategory = category
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                        
                        // Templates Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(filteredTemplates) { template in
                                TemplateCard(template: template) {
                                    selectedBeacon = template.toBeacon()
                                    dismiss()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Choose Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    var filteredTemplates: [BeaconTemplate] {
        if let category = selectedCategory {
            return templateManager.templates(for: category)
        }
        return templateManager.templates
    }
}

struct CategoryButton: View {
    let category: BeaconTemplate.SportCategory?
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? Color(hex: "#FF3C00") : Color.gray.opacity(0.15))
            )
        }
    }
}

struct TemplateCard: View {
    let template: BeaconTemplate
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [template.color.color.opacity(0.25), template.color.color.opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(template.color.color.opacity(0.3), lineWidth: 2)
                        )
                        .shadow(color: template.color.color.opacity(0.3), radius: 12, x: 0, y: 6)
                    
                    Image(systemName: template.iconName)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(template.color.color)
                }
                
                VStack(spacing: 6) {
                    Text(template.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text(template.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    // Zone info
                    HStack(spacing: 4) {
                        Text("\(String(format: "%.0f", template.minValue))")
                            .font(.caption2)
                            .fontWeight(.bold)
                        Text("→")
                            .font(.caption2)
                        Text("\(String(format: "%.0f", template.maxValue))")
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(template.color.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(template.color.color.opacity(0.1))
                    )
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
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
