//
//  StatisticsView.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import SwiftUI

struct StatisticsView: View {
    @StateObject private var viewModel: StatisticsViewModel
    @Environment(\.dismiss) var dismiss
    
    init(beacon: Beacon) {
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(beacon: beacon))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Overview Cards
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            StatCard(title: "Average", value: String(format: "%.1f", viewModel.averageValue), color: .blue)
                            StatCard(title: "In Zone", value: String(format: "%.0f%%", viewModel.inZonePercentage), color: .green)
                            StatCard(title: "Min", value: String(format: "%.1f", viewModel.minValue), color: .gray)
                            StatCard(title: "Max", value: String(format: "%.1f", viewModel.maxValue), color: .gray)
                        }
                        .padding(.horizontal)
                        
                        // Trend Card
                        TrendCard(trend: viewModel.trend)
                            .padding(.horizontal)
                        
                        // Activity Stats
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Activity")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ActivityRow(title: "Total Readings", value: "\(viewModel.totalReadings)")
                            ActivityRow(title: "Last 24 Hours", value: "\(viewModel.last24HoursCount)")
                            ActivityRow(title: "Last 7 Days", value: "\(viewModel.last7DaysCount)")
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.loadReadings()
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct TrendCard: View {
    let trend: Trend
    
    var body: some View {
        HStack {
            Image(systemName: trend.icon)
                .font(.title2)
                .foregroundColor(trend.color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Trend")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(trend.description)
                    .font(.headline)
                    .foregroundColor(trend.color)
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ActivityRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}
