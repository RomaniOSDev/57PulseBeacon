//
//  BeaconChartShape.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import SwiftUI

struct BeaconChartShape: Shape {
    let readings: [BeaconReading]
    let beacon: Beacon
    let minY: Double
    let maxY: Double
    let scrollOffset: CGFloat
    let visibleWidth: CGFloat
    let padding: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard !readings.isEmpty else { return path }
        
        let chartWidth = rect.width - padding * 2
        let chartHeight = rect.height - padding * 2
        let range = max(maxY - minY, 1.0)
        
        // Calculate point spacing based on visible width
        let pointSpacing = chartWidth / CGFloat(max(readings.count - 1, 1))
        
        // Calculate which points are visible
        let startIndex = max(0, Int(scrollOffset / pointSpacing))
        let endIndex = min(readings.count - 1, Int((scrollOffset + visibleWidth) / pointSpacing) + 1)
        
        guard startIndex < readings.count else { return path }
        
        // Draw line segments with color based on status
        for i in startIndex..<endIndex {
            if i < readings.count - 1 {
                let reading1 = readings[i]
                let reading2 = readings[i + 1]
                
                let x1 = padding + CGFloat(i) * pointSpacing - scrollOffset
                let y1 = padding + chartHeight - CGFloat((reading1.value - minY) / range) * chartHeight
                
                let x2 = padding + CGFloat(i + 1) * pointSpacing - scrollOffset
                let y2 = padding + chartHeight - CGFloat((reading2.value - minY) / range) * chartHeight
                
                // Only draw if segment is visible
                if x2 >= padding && x1 <= rect.width - padding {
                    path.move(to: CGPoint(x: x1, y: y1))
                    path.addLine(to: CGPoint(x: x2, y: y2))
                }
            }
        }
        
        return path
    }
}

struct BeaconChartSegmentShape: Shape {
    let point1: CGPoint
    let point2: CGPoint
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: point1)
        path.addLine(to: point2)
        return path
    }
}
