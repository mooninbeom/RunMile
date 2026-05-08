//
//  WorkoutDetailPrototypeView.swift
//  Run Mile
//
//  Created by Antigravity on 12/18/25.
//

import SwiftUI


struct WorkoutDetailView: View {
    @State private var viewModel: WorkoutDetailViewModel
    @Namespace private var mapNamespace
    
    init(viewModel: WorkoutDetailViewModel) {
        self.viewModel = viewModel
    }
    
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    //  MARK: - Header Summary
                    HeaderSummarySection(
                        viewModel: $viewModel,
                        namespace: mapNamespace
                    )
                    
                    // MARK: - Charts
                    ChartSection(viewModel: $viewModel)
                    
                    // MARK: - Detailed Stats Grid
                    AllStatsGridSection(viewModel: $viewModel)
                    
                    // MARK: - Splits
                    SplitSection(viewModel: $viewModel)
                }
                .padding(.bottom, 40)
            }
            .task {
                await viewModel.onAppear()
            }
            .background(RunMileColor.background)
            .navigationTitle("운동 상세")
            .navigationBarTitleDisplayMode(.inline)
            
            // MARK: - Full Screen Map Overlay
            ExtendedMapView(
                viewModel: self.$viewModel,
                namespace: mapNamespace
            )
            
        }
        .toolbar(viewModel.showFullMap ? .hidden : .visible, for: .navigationBar)
        .toolbar(viewModel.showFullMap ? .hidden : .visible, for: .tabBar)
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailView(
            viewModel: PreviewDIContainer().makeWorkoutDetailViewModel(
                workout: PreviewShoesMockData.primaryWorkout
            )
        )
    }
}
