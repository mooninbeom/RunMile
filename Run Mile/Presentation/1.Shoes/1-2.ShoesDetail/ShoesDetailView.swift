//
//  ShoesDetailView.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import SwiftUI


struct ShoesDetailView: View {
    @State private var viewModel: ShoesDetailViewModel
    
    init(viewModel: ShoesDetailViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ShoesDetailHeaderView(
                    shoes: viewModel.shoes,
                    brand: viewModel.shoeBrand,
                    model: viewModel.shoeModel,
                    onImageTap: viewModel.imageTapped,
                    onHallOfFameTap: viewModel.HOFButtonTapped
                )
                
                ShoesDetailMileageCardView(
                    shoes: viewModel.shoes,
                    remainingPercentText: viewModel.remainingPercentText,
                    lifeSpanRatio: viewModel.lifeSpanRatio,
                    statusColor: viewModel.statusColor,
                    statusForegroundColor: viewModel.statusForegroundColor,
                    averageDistance: viewModel.averageDistance
                )
                
                ShoesDetailManagementSection(
                    workoutCount: viewModel.shoes.workouts.count,
                    currentMileageText: viewModel.shoes.getCurrentMileage,
                    onEditInfoTap: viewModel.editInfoButtonTapped,
                    onWorkoutManagementTap: viewModel.workoutManagementButtonTapped
                )
                
                ShoesDetailWorkoutHistoryView(
                    workouts: viewModel.shoes.workouts,
                    shoesName: viewModel.shoes.shoesName,
                    onWorkoutTap: viewModel.workoutCellTapped
                )
                
                ShoesDetailDangerSection(
                    onDeleteTap: viewModel.deleteManagementButtonTapped
                )
            }
            .padding(.bottom, 40)
        }
        .background(RunMileColor.background)
        .navigationTitle(viewModel.shoeModel)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $viewModel.activeManagementSheet, content: managementSheet)
    }
    
    @ViewBuilder
    private func managementSheet(_ sheet: ShoesDetailViewModel.ManagementSheet) -> some View {
        switch sheet {
        case .editInfo:
            ShoesEditSheetView(
                brand: $viewModel.editBrand,
                model: $viewModel.editModel,
                customBrand: $viewModel.editCustomBrand,
                customModel: $viewModel.editCustomModel,
                usage: $viewModel.editUsage,
                goalMileage: $viewModel.editGoalMileage,
                brandList: viewModel.editBrandList,
                modelList: viewModel.editModelList,
                isDoneEnabled: viewModel.isEditSaveEnabled,
                onCancel: viewModel.dismissManagementSheet,
                onDone: viewModel.saveEditedShoes
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        case .workouts:
            ShoesWorkoutManagementSheet(
                workouts: viewModel.shoes.workouts,
                selectedWorkoutIDs: $viewModel.selectedWorkoutIDs,
                onCancel: viewModel.dismissManagementSheet,
                onRemove: viewModel.removeSelectedWorkouts
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        case .delete:
            ShoesDeleteSheetView(
                shoesName: viewModel.shoes.shoesName,
                workoutCount: viewModel.shoes.workouts.count,
                onCancel: viewModel.dismissManagementSheet,
                onDelete: viewModel.deleteShoesFromSheet
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}


#if DEBUG
#Preview {
    NavigationStack {
        ShoesDetailView(
            viewModel: PreviewDIContainer().makeShoesDetailViewModel(
                shoes: PreviewShoesMockData.primaryShoes
            )
        )
    }
}
#endif
