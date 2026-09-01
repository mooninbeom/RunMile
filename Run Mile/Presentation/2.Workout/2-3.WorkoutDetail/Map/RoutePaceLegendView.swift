//
//  RoutePaceLegendView.swift
//  Run Mile
//
//  Created by Codex on 5/3/26.
//

import SwiftUI


struct RoutePaceLegendView: View {
    let fastestPace: String
    let slowestPace: String
    
    private let legendWidth: CGFloat = 118
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            LinearGradient(
                colors: [.green, .yellow, .red],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: legendWidth, height: 7)
            .clipShape(RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                    .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
            }
            
            HStack {
                Text(fastestPace)
                Spacer(minLength: 0)
                Text(slowestPace)
            }
            .frame(width: legendWidth)
            .font(.caption2.weight(.semibold))
            .monospacedDigit()
            .foregroundStyle(RunMileColor.foreground)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                .fill(RunMileColor.mapOverlaySurface)
                .shadow(color: RunMileColor.hardShadow, radius: 0, x: 3, y: 3)
        }
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
        }
    }
}


extension WorkoutRouteSegment {
    var routeColor: Color {
        let ratio = min(max(paceRatio, 0), 1)
        
        if ratio <= 0.5 {
            return Self.interpolateColor(
                from: .init(red: 0.25, green: 0.84, blue: 0.39),
                to: .init(red: 1.00, green: 0.86, blue: 0.22),
                progress: ratio / 0.5
            )
        }
        
        return Self.interpolateColor(
            from: .init(red: 1.00, green: 0.86, blue: 0.22),
            to: .init(red: 1.00, green: 0.29, blue: 0.25),
            progress: (ratio - 0.5) / 0.5
        )
    }
    
    private static func interpolateColor(from start: RGBColor, to end: RGBColor, progress: Double) -> Color {
        let clampedProgress = min(max(progress, 0), 1)
        
        return Color(
            red: start.red + (end.red - start.red) * clampedProgress,
            green: start.green + (end.green - start.green) * clampedProgress,
            blue: start.blue + (end.blue - start.blue) * clampedProgress
        )
    }
}


private struct RGBColor {
    let red: Double
    let green: Double
    let blue: Double
}
