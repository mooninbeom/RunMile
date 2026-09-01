//
//  ShoesDarkModePreviewView.swift
//  Run Mile
//
//  Created by Codex on 8/30/26.
//

#if DEBUG
import SwiftUI


#Preview("Shoes List · Light") {
    NavigationStack {
        ShoesListView(viewModel: PreviewDIContainer().makeShoesListViewModel())
    }
    .preferredColorScheme(.light)
}


#Preview("Shoes List · Dark") {
    NavigationStack {
        ShoesListView(viewModel: PreviewDIContainer().makeShoesListViewModel())
    }
    .preferredColorScheme(.dark)
}


#Preview("Add Shoes · Light") {
    AddShoesView(
        viewModel: PreviewDIContainer().makeAddShoesViewModel(),
        dismissAction: {}
    )
    .preferredColorScheme(.light)
}


#Preview("Add Shoes · Dark") {
    AddShoesView(
        viewModel: PreviewDIContainer().makeAddShoesViewModel(),
        dismissAction: {}
    )
    .preferredColorScheme(.dark)
}


#Preview("Shoes Detail · Light") {
    NavigationStack {
        ShoesDetailView(
            viewModel: PreviewDIContainer().makeShoesDetailViewModel(
                shoes: PreviewShoesMockData.primaryShoes
            )
        )
    }
    .preferredColorScheme(.light)
}


#Preview("Shoes Detail · Dark") {
    NavigationStack {
        ShoesDetailView(
            viewModel: PreviewDIContainer().makeShoesDetailViewModel(
                shoes: PreviewShoesMockData.primaryShoes
            )
        )
    }
    .preferredColorScheme(.dark)
}


#Preview("Shoes Edit Sheet · Dark") {
    ShoesEditSheetPreviewContainer()
        .preferredColorScheme(.dark)
}


#Preview("Workout Management Sheet · Dark") {
    ShoesWorkoutManagementSheetPreviewContainer()
        .preferredColorScheme(.dark)
}


#Preview("Shoes Delete Sheet · Dark") {
    ShoesDeleteSheetView(
        shoesName: PreviewShoesMockData.primaryShoes.shoesName,
        workoutCount: PreviewShoesMockData.primaryShoes.workouts.count,
        onCancel: {},
        onDelete: {}
    )
    .preferredColorScheme(.dark)
}


#Preview("Notification Permission Sheet · Dark") {
    ZStack {
        RunMileColor.loadingScrim
            .ignoresSafeArea()

        VStack {
            Spacer()

            AddShoesNotificationPermissionSheet(onConfirm: {})
        }
        .ignoresSafeArea(edges: .bottom)
    }
    .preferredColorScheme(.dark)
}


@MainActor
private struct ShoesEditSheetPreviewContainer: View {
    @State private var imageEditorViewModel = ShoeImageEditorViewModel(
        imageData: Data(),
        normalizeImage: { $0 },
        removeBackground: { $0 }
    )
    @State private var brand = ShoeCatalog.defaultBrand
    @State private var model = ShoeCatalog.defaultModel
    @State private var customBrand = ""
    @State private var customModel = ""
    @State private var usage = "데일리 러닝"
    @State private var goalMileage = "700"

    var body: some View {
        ShoesEditSheetView(
            imageEditorViewModel: imageEditorViewModel,
            brand: $brand,
            model: $model,
            customBrand: $customBrand,
            customModel: $customModel,
            usage: $usage,
            goalMileage: $goalMileage,
            brandList: ShoeCatalog.brandList,
            modelList: ShoeCatalog.modelList(for: brand),
            isDoneEnabled: true,
            onCancel: {},
            onDone: {}
        )
    }
}


private struct ShoesWorkoutManagementSheetPreviewContainer: View {
    @State private var selectedWorkoutIDs = Set<UUID>()

    var body: some View {
        ShoesWorkoutManagementSheet(
            workouts: PreviewShoesMockData.workouts,
            selectedWorkoutIDs: $selectedWorkoutIDs,
            onCancel: {},
            onRemove: {}
        )
    }
}
#endif
