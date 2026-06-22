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
            let valueFontSize = headerMetricValueFontSize(for: geometry.size.width)

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.workoutStartDate)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white.opacity(0.8))

                Text(viewModel.workoutTitle)
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundStyle(.white)

                HStack(spacing: 20) {
                    HeaderMetric(value: viewModel.distance, label: "킬로미터", valueFontSize: valueFontSize)
                    HeaderMetric(value: viewModel.elapsedTime, label: "시간", valueFontSize: valueFontSize)
                    HeaderMetric(value: viewModel.calories, label: "KCAL", valueFontSize: valueFontSize)
                }
                .padding(.top, 10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
    }

    private func headerMetricValueFontSize(for width: CGFloat) -> CGFloat {
        width < 320 ? 28 : 32
    }
}


private struct HeaderMetric: View {
    let value: String
    let label: String
    let valueFontSize: CGFloat

    var body: some View {
        VStack(alignment: .leading) {
            Text(value)
                .font(.system(size: valueFontSize, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.8))
        }
    }
}
