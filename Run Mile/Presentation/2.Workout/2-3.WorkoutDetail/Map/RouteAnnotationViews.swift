//
//  RouteAnnotationViews.swift
//  Run Mile
//
//  Created by 문인범 on 1/6/26.
//

import SwiftUI


enum RouteEndpoint {
    case start
    case end

    var color: Color {
        switch self {
        case .start:
            return RunMileColor.success
        case .end:
            return RunMileColor.primary
        }
    }

    var accessibilityText: String {
        switch self {
        case .start:
            return "시작점"
        case .end:
            return "끝점"
        }
    }
}


struct RouteEndpointAnnotationView: View {
    let endpoint: RouteEndpoint

    var body: some View {
        ZStack {
            Circle()
                .fill(RunMileColor.hardShadow)
                .frame(width: 18, height: 18)
                .offset(x: 1.5, y: 1.5)

            Circle()
                .fill(RunMileColor.card)
                .frame(width: 18, height: 18)
                .overlay {
                    Circle()
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
                }

            Circle()
                .fill(endpoint.color)
                .frame(width: 11, height: 11)
        }
        .frame(width: 20, height: 20)
        .accessibilityLabel(endpoint.accessibilityText)
    }
}


struct SelectedRouteAnnotationView: View {
    let pace: String

    var body: some View {
        ZStack {
            SelectedRouteMarkerDot()

            Text(pace)
                .font(.caption2.weight(.black))
                .monospacedDigit()
                .foregroundStyle(RunMileColor.foreground)
                .padding(.vertical, 6)
                .padding(.horizontal, 9)
                .background {
                    RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                        .fill(RunMileColor.mapOverlaySurface)
                        .shadow(color: RunMileColor.hardShadow, radius: 0, x: 2, y: 2)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                }
                .offset(y: -32)
        }
    }
}


private struct SelectedRouteMarkerDot: View {
    private let markerSize: CGFloat = 24
    private let centerSize: CGFloat = 12

    var body: some View {
        ZStack {
            Circle()
                .fill(RunMileColor.hardShadow)
                .frame(width: markerSize, height: markerSize)
                .offset(x: 2, y: 2)

            Circle()
                .fill(RunMileColor.card)
                .frame(width: markerSize, height: markerSize)
                .overlay {
                    Circle()
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                }

            Circle()
                .fill(RunMileColor.primary)
                .frame(width: centerSize, height: centerSize)
        }
        .frame(width: markerSize + 2, height: markerSize + 2)
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
                    .foregroundStyle(RunMileColor.primaryStrong)

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
                        .shadow(color: RunMileColor.hardShadow.opacity(0.72), radius: 0, x: 2, y: 2)
            }
            .overlay {
                RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                    .stroke(RunMileColor.border.opacity(0.9), lineWidth: RunMileStroke.border)
            }
            .offset(y: -28)
        }
    }
}
