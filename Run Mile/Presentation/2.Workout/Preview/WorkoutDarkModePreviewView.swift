//
//  WorkoutDarkModePreviewView.swift
//  Run Mile
//
//  Created by Codex on 8/30/26.
//

#if DEBUG
import SwiftUI


#Preview("Workout List · Light") {
    NavigationStack {
        WorkoutListView(viewModel: PreviewDIContainer().makeWorkoutListViewModel())
    }
    .preferredColorScheme(.light)
}


#Preview("Workout List · Dark") {
    NavigationStack {
        WorkoutListView(viewModel: PreviewDIContainer().makeWorkoutListViewModel())
    }
    .preferredColorScheme(.dark)
}


#Preview("Choose Shoes · Light") {
    ChooseShoesView(
        viewModel: PreviewDIContainer().makeChooseShoesViewModel(
            workouts: Array(PreviewShoesMockData.workouts.prefix(2))
        )
    )
    .preferredColorScheme(.light)
}


#Preview("Choose Shoes · Dark") {
    ChooseShoesView(
        viewModel: PreviewDIContainer().makeChooseShoesViewModel(
            workouts: Array(PreviewShoesMockData.workouts.prefix(2))
        )
    )
    .preferredColorScheme(.dark)
}


#Preview("Auto Mileage · Light") {
    AutoMileageShoesView(
        viewModel: PreviewDIContainer().makeAutoMileageShoesViewModel()
    )
    .preferredColorScheme(.light)
}


#Preview("Auto Mileage · Dark") {
    AutoMileageShoesView(
        viewModel: PreviewDIContainer().makeAutoMileageShoesViewModel()
    )
    .preferredColorScheme(.dark)
}


#Preview("Workout Detail · Light") {
    NavigationStack {
        WorkoutDetailView(
            viewModel: PreviewDIContainer().makeWorkoutDetailViewModel(
                workout: PreviewShoesMockData.primaryWorkout
            )
        )
    }
    .preferredColorScheme(.light)
}


#Preview("Workout Detail · Dark") {
    NavigationStack {
        WorkoutDetailView(
            viewModel: PreviewDIContainer().makeWorkoutDetailViewModel(
                workout: PreviewShoesMockData.primaryWorkout
            )
        )
    }
    .preferredColorScheme(.dark)
}


#Preview("Map Analysis · Light") {
    WorkoutMapAnalysisPreviewContainer()
        .preferredColorScheme(.light)
}


#Preview("Map Analysis · Dark") {
    WorkoutMapAnalysisPreviewContainer()
        .preferredColorScheme(.dark)
}


@MainActor
private struct WorkoutMapAnalysisPreviewContainer: View {
    @State private var viewModel: WorkoutDetailViewModel
    @Namespace private var mapNamespace

    init() {
        let viewModel = PreviewDIContainer().makeWorkoutDetailViewModel(
            workout: PreviewShoesMockData.primaryWorkout
        )
        viewModel.configureMapAnalysisPreview(
            detail: PreviewWorkoutMockData.detail,
            selectedSeconds: 900
        )
        viewModel.showFullMap = true
        viewModel.showMapAnalysis = true
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            RunMileColor.background
                .ignoresSafeArea()

            ExtendedMapView(
                viewModel: $viewModel,
                namespace: mapNamespace
            )
        }
    }
}
#endif
