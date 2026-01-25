//
//  MiniChartView.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import SwiftUI

struct MiniChartView: View {
    let readings: [BeaconReading]
    let beacon: Beacon
    let minY: Double
    let maxY: Double
    
    var body: some View {
        GeometryReader { geometry in
            let padding: CGFloat = 8
            let chartWidth = geometry.size.width - padding * 2
            let chartHeight = geometry.size.height - padding * 2
            let range = max(maxY - minY, 1.0)
            
            ZStack {
                // Target zone background
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(
                        width: chartWidth,
                        height: CGFloat((beacon.maxValue - beacon.minValue) / range) * chartHeight
                    )
                    .offset(y: padding + chartHeight - CGFloat((beacon.maxValue - minY) / range) * chartHeight - chartHeight / 2)
                
                // Chart line
                if readings.count > 1 {
                    Path { path in
                        let pointSpacing = chartWidth / CGFloat(max(readings.count - 1, 1))
                        
                        for (index, reading) in readings.enumerated() {
                            let x = padding + CGFloat(index) * pointSpacing
                            let y = padding + chartHeight - CGFloat((reading.value - minY) / range) * chartHeight
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color.blue, lineWidth: 2)
                }
            }
        }
    }
}
