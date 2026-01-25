//
//  HistoryView.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import SwiftUI

struct HistoryView: View {
    let beacon: Beacon
    @StateObject private var viewModel: HistoryViewModel
    @Environment(\.dismiss) var dismiss
    @State private var lastDragValue: CGFloat = 0
    @State private var chartWidth: CGFloat = 300
    
    init(beacon: Beacon) {
        self.beacon = beacon
        _viewModel = StateObject(wrappedValue: HistoryViewModel(beacon: beacon))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                if viewModel.readings.isEmpty {
                    VStack {
                        Text("No data yet")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                } else {
                    VStack(spacing: 20) {
                        // Chart
                        GeometryReader { geometry in
                            let width = geometry.size.width
                            
                            ZStack {
                                // Target zone background
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(
                                        width: width,
                                        height: zoneHeight(in: geometry)
                                    )
                                    .offset(y: zoneOffset(in: geometry))
                                
                                // Chart lines with color segments
                                chartLines(in: geometry, width: width)
                                
                                // Y-axis labels
                                VStack {
                                    Text(String(format: "%.0f", viewModel.maxValue))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(String(format: "%.0f", viewModel.minValue))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.leading, 8)
                                
                                // X-axis labels
                                HStack {
                                    Text("\(visibleStartIndex(width: width) + 1)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("\(visibleEndIndex(width: width) + 1)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 40)
                                .offset(y: geometry.size.height - 20)
                            }
                            .onAppear {
                                chartWidth = width
                            }
                            .onChange(of: width) { newWidth in
                                chartWidth = newWidth
                            }
                        }
                        .frame(height: 300)
                        .padding()
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let delta = value.translation.width - lastDragValue
                                    lastDragValue = value.translation.width
                                    let maxOffset = viewModel.maxScrollOffset(for: chartWidth)
                                    let newOffset = max(0, min(maxOffset, viewModel.scrollOffset - delta))
                                    viewModel.scrollOffset = newOffset
                                }
                                .onEnded { _ in
                                    lastDragValue = 0
                                }
                        )
                        
                        // Scroll indicator
                        if viewModel.maxScrollOffset(for: chartWidth) > 0 {
                            HStack {
                                Text("Drag to scroll")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Legend
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 20, height: 20)
                                Text("Target Zone: \(String(format: "%.0f", beacon.minValue)) - \(String(format: "%.0f", beacon.maxValue))")
                                    .font(.caption)
                            }
                            
                            HStack {
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: 20, height: 3)
                                Text("In Zone")
                                    .font(.caption)
                            }
                            
                            HStack {
                                Rectangle()
                                    .fill(Color(hex: "#FF3C00"))
                                    .frame(width: 20, height: 3)
                                Text("Out of Zone / Critical")
                                    .font(.caption)
                            }
                        }
                        .padding()
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("History")
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
    
    private func chartLines(in geometry: GeometryProxy, width: CGFloat) -> some View {
        let padding: CGFloat = 40
        let chartWidth = width - padding * 2
        let chartHeight = geometry.size.height - padding * 2
        let minY = viewModel.minValue
        let maxY = viewModel.maxValue
        let range = max(maxY - minY, 1.0)
        let pointSpacing = chartWidth / CGFloat(max(viewModel.readings.count - 1, 1))
        
        return ZStack {
            ForEach(0..<viewModel.readings.count - 1, id: \.self) { index in
                let reading1 = viewModel.readings[index]
                let reading2 = viewModel.readings[index + 1]
                
                let x1 = padding + CGFloat(index) * pointSpacing - viewModel.scrollOffset
                let y1 = padding + chartHeight - CGFloat((reading1.value - minY) / range) * chartHeight
                
                let x2 = padding + CGFloat(index + 1) * pointSpacing - viewModel.scrollOffset
                let y2 = padding + chartHeight - CGFloat((reading2.value - minY) / range) * chartHeight
                
                // Only draw if segment is visible
                if x2 >= padding - 10 && x1 <= width - padding + 10 {
                    let status1 = beacon.status(for: reading1.value)
                    let status2 = beacon.status(for: reading2.value)
                    
                    // Use color based on both points - if either is out of zone, use red
                    let lineColor: Color = (status1 == .inZone && status2 == .inZone) ? .black : Color(hex: "#FF3C00")
                    
                    BeaconChartSegmentShape(point1: CGPoint(x: x1, y: y1), point2: CGPoint(x: x2, y: y2))
                        .stroke(lineColor, lineWidth: 2)
                }
            }
        }
    }
    
    private func visibleStartIndex(width: CGFloat) -> Int {
        let padding: CGFloat = 40
        let chartWidth = width - padding * 2
        let pointSpacing = chartWidth / CGFloat(max(viewModel.readings.count - 1, 1))
        return max(0, Int(viewModel.scrollOffset / pointSpacing))
    }
    
    private func visibleEndIndex(width: CGFloat) -> Int {
        let padding: CGFloat = 40
        let chartWidth = width - padding * 2
        let pointSpacing = chartWidth / CGFloat(max(viewModel.readings.count - 1, 1))
        let visibleWidth = chartWidth
        return min(viewModel.readings.count - 1, Int((viewModel.scrollOffset + visibleWidth) / pointSpacing))
    }
    
    private func zoneHeight(in geometry: GeometryProxy) -> CGFloat {
        let padding: CGFloat = 40
        let chartHeight = geometry.size.height - padding * 2
        let minY = viewModel.minValue
        let maxY = viewModel.maxValue
        let totalRange = max(maxY - minY, 1.0)
        let zoneRange = beacon.maxValue - beacon.minValue
        return CGFloat(zoneRange / totalRange) * chartHeight
    }
    
    private func zoneOffset(in geometry: GeometryProxy) -> CGFloat {
        let padding: CGFloat = 40
        let chartHeight = geometry.size.height - padding * 2
        let minY = viewModel.minValue
        let maxY = viewModel.maxValue
        let totalRange = max(maxY - minY, 1.0)
        // Calculate where the top of the zone should be
        let zoneTopFromMin = beacon.maxValue - minY
        let zoneTopY = CGFloat(zoneTopFromMin / totalRange) * chartHeight
        let centerY = geometry.size.height / 2
        return padding + chartHeight - zoneTopY - centerY
    }
}
