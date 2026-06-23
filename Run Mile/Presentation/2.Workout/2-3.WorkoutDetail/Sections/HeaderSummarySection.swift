//
//  HeaderSummarySection.swift
//  Run Mile
//
//  Created by 문인범 on 1/6/26.
//

import SwiftUI
import MapKit


struct HeaderSummarySection: View {
    @Binding var viewModel: WorkoutDetailViewModel
    var namespace: Namespace.ID

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                .fill(RunMileColor.border)
                .offset(x: 4, y: 4)
                .zIndex(0)

            heroCardContent
                .zIndex(1)
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }

    private var heroCardContent: some View {
        ZStack(alignment: .bottomLeading) {
            mapBackground
                .zIndex(0)

            LinearGradient(
                colors: [.black.opacity(0.8), .clear],
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 350)
            .allowsHitTesting(false)
            .zIndex(1)

            headerContent
                .padding(20)
                .zIndex(2)
        }
        .clipShape(RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
        }
    }

    @ViewBuilder
    private var mapBackground: some View {
        if #available(iOS 17.0, *) {
            if !viewModel.showFullMap {
                Map {
                    if viewModel.routeSegments.isEmpty {
                        MapPolyline(coordinates: viewModel.polylines)
                            .stroke(RunMileColor.success, lineWidth: 4)
                    } else {
                        ForEach(viewModel.routeSegments) { segment in
                            MapPolyline(coordinates: segment.coordinates)
                                .stroke(
                                    segment.routeColor,
                                    style: RouteMapLineStyle.dottedStroke(lineWidth: 4)
                                )
                        }
                    }

                    if let startCoordinate = viewModel.routeStartCoordinate {
                        Annotation("", coordinate: startCoordinate) {
                            RouteEndpointAnnotationView(endpoint: .start)
                        }
                    }

                    if let endCoordinate = viewModel.routeEndCoordinate {
                        Annotation("", coordinate: endCoordinate) {
                            RouteEndpointAnnotationView(endpoint: .end)
                        }
                    }

                    if let marker = viewModel.selectedRouteMarker {
                        Annotation("", coordinate: marker.coordinate) {
                            SelectedRouteAnnotationView(pace: marker.pace)
                        }
                    } else if let marker = viewModel.fastestRouteMarker {
                        Annotation("", coordinate: marker.coordinate) {
                            FastestPaceAnnotationView(pace: marker.pace)
                        }
                    }
                }
                .matchedGeometryEffect(id: "Map", in: namespace)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 150)
                }
                .frame(height: 350)
                .allowsHitTesting(false)
                .overlay {
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring) {
                                viewModel.headerMapTapped()
                            }
                        }
                }
            } else {
                Rectangle()
                    .fill(RunMileColor.muted)
                    .frame(height: 350)
            }
        } else {
            LinearGradient(
                colors: [RunMileColor.chart4.opacity(0.8), RunMileColor.accent.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 350)
        }
    }

    private var headerContent: some View {
        GeometryReader { geometry in
            let metricLayout = HeaderMetricLayout(width: geometry.size.width)

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.workoutStartDate)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white.opacity(0.8))

                Text(viewModel.workoutTitle)
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundStyle(.white)

                HStack(alignment: .bottom, spacing: metricLayout.spacing) {
                    HeaderMetric(value: viewModel.distance, label: "킬로미터", layout: metricLayout)
                    HeaderMetric(value: viewModel.elapsedTime, label: "시간", layout: metricLayout)
                        .layoutPriority(1)
                    HeaderMetric(value: viewModel.calories, label: "KCAL", layout: metricLayout)
                }
                .padding(.top, metricLayout.topPadding)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
    }
}

private struct HeaderMetricLayout {
    let valueFontSize: CGFloat
    let labelFont: Font
    let spacing: CGFloat
    let topPadding: CGFloat

    init(width: CGFloat) {
        switch width {
        case ..<285:
            valueFontSize = 22
            labelFont = .caption2
            spacing = RunMileSpacing.small
            topPadding = RunMileSpacing.small
        case ..<325:
            valueFontSize = 24
            labelFont = .caption2
            spacing = RunMileSpacing.small
            topPadding = RunMileSpacing.small
        case ..<365:
            valueFontSize = 28
            labelFont = .caption
            spacing = RunMileSpacing.medium
            topPadding = RunMileSpacing.small
        default:
            valueFontSize = 32
            labelFont = .caption
            spacing = RunMileSpacing.large
            topPadding = RunMileSpacing.medium
        }
    }
}


private struct HeaderMetric: View {
    let value: String
    let label: String
    let layout: HeaderMetricLayout

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(value)
                .font(Font(UIFont.systemFont(ofSize: layout.valueFontSize, weight: .bold, width: .condensed)))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .allowsTightening(true)

            Text(label)
                .font(layout.labelFont)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.8))
                .lineLimit(1)
                .minimumScaleFactor(0.9)
        }
    }
}
