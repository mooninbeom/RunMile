//
//  RouteAnnotationViews.swift
//  Run Mile
//
//  Created by 문인범 on 1/6/26.
//

import SwiftUI


struct SelectedRouteAnnotationView: View {
    let pace: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(RunMileColor.card)
                .frame(width: 24, height: 24)
                .overlay {
                    Circle()
                        .fill(RunMileColor.primary)
                        .frame(width: 12, height: 12)
                }
                .overlay {
                    Circle()
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                }
                .shadow(color: RunMileColor.border, radius: 0, x: 2, y: 2)
            
            Text(pace)
                .font(.caption2.weight(.black))
                .monospacedDigit()
                .foregroundStyle(RunMileColor.foreground)
                .padding(.vertical, 6)
                .padding(.horizontal, 9)
                .background {
                    RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                        .fill(RunMileColor.card)
                        .shadow(color: RunMileColor.border, radius: 0, x: 2, y: 2)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                }
                .offset(y: -32)
        }
    }
}


struct FastestPaceAnnotationView: View {
    let pace: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(RunMileColor.primary)
                .frame(width: 12, height: 12)
                .overlay {
                    Circle()
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
                }
            
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(RunMileColor.primary)

                Text("최고 \(pace)")
                    .font(.caption.weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(RunMileColor.secondaryForeground)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background {
                RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                    .fill(RunMileColor.secondary.opacity(0.86))
                    .shadow(color: RunMileColor.border.opacity(0.72), radius: 0, x: 2, y: 2)
            }
            .overlay {
                RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                    .stroke(RunMileColor.border.opacity(0.9), lineWidth: RunMileStroke.border)
            }
            .offset(y: -28)
        }
    }
}
