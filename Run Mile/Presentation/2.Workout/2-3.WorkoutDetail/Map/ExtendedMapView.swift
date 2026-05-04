//
//  ExtendedMapView.swift
//  Run Mile
//
//  Created by 문인범 on 1/6/26.
//

import SwiftUI
import MapKit



struct ExtendedMapView: View {
    @Binding var viewModel: WorkoutDetailViewModel
    var namespace: Namespace.ID
    
    var body: some View {
        if viewModel.showFullMap {
            ZStack(alignment: .topLeading) {
                if #available(iOS 17.0, *) {
                    Map {
                        if viewModel.routeSegments.isEmpty {
                            MapPolyline(coordinates: viewModel.polylines)
                                .stroke(.green, lineWidth: 5)
                        } else {
                            ForEach(viewModel.routeSegments) { segment in
                                MapPolyline(coordinates: segment.coordinates)
                                    .stroke(
                                        segment.routeColor,
                                        style: StrokeStyle(
                                            lineWidth: 6,
                                            lineCap: .round,
                                            lineJoin: .round
                                        )
                                    )
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
                    .ignoresSafeArea()
                }
                
                if !viewModel.routeSegments.isEmpty {
                    HStack {
                        Spacer()
                        
                        RoutePaceLegendView(
                            fastestPace: viewModel.routeFastestPace,
                            slowestPace: viewModel.routeSlowestPace
                        )
                            .padding(.top, 62)
                            .padding(.trailing, 16)
                    }
                }
                
                // Close Button
                Button {
                    withAnimation(.spring) {
                        viewModel.fullMapCloseButtonTapped()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.white, .gray.opacity(0.5))
                        .padding()
                        .padding(.top, 40)
                }
                
	                // Bottom Analysis Trigger Button
	                if !viewModel.showMapAnalysis {
	                    VStack {
	                        Spacer()
	                        HStack {
	                            Spacer()
	                            Button {
	                                withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
	                                    viewModel.mapAnalysisButtonTapped()
	                                }
	                            } label: {
	                                HStack(spacing: 8) {
	                                    Image(systemName: "chart.xyaxis.line")
	                                        .font(.headline)
	                                    Text("분석 보기")
	                                        .font(.headline)
	                                }
	                                .foregroundStyle(.black)
	                                .padding(.vertical, 12)
	                                .padding(.horizontal, 24)
	                                .background {
	                                    Capsule()
	                                        .fill(.white)
	                                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
	                                }
	                            }
	                            .padding(.bottom, 60)
	                            Spacer()
	                        }
	                    }
	                    .zIndex(2)
	                }
	                
	                if viewModel.showMapAnalysis {
	                    VStack {
	                        Spacer()
	                        
	                        MapAnalysisBottomPanel(viewModel: $viewModel)
	                        .padding(.horizontal, 14)
	                        .padding(.bottom, 18)
	                        .transition(.move(edge: .bottom).combined(with: .opacity))
	                    }
	                    .zIndex(3)
	                }
	            }
	            .zIndex(1) // Ensure it overlays everything
	            .transition(.asymmetric(insertion: .identity, removal: .identity))
	            .ignoresSafeArea()
	        }
	    }
}
