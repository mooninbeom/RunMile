//
//  WorkoutListView.swift
//  Run Mile
//
//  Created by 문인범 on 4/16/25.
//

import SwiftUI


struct WorkoutListView: View {
    @State private var viewModel: WorkoutListViewModel = .init(
        useCase: DefaultHealthDataUseCase(
            workoutDataRepository: WorkoutDataRepositoryImpl(),
            shoesDataRepository: ShoesDataRepositoryImpl()
        )
    )
    
    var body: some View {
        VStack(spacing: 0) {
            WorkoutNavigationView(viewModel: viewModel)
            
            switch viewModel.viewStatus {
            case .none:
                WorkoutScrollView(viewModel: $viewModel)
            case .loading:
                WorkoutLoadingView()
            case .empty:
                WorkoutEmptyView(
                    viewModel: viewModel
                )
            }
        }
        .task {
            await viewModel.onAppear()
        }
    }
}


private struct WorkoutNavigationView: View {
    let viewModel: WorkoutListViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("운동 등록")
                    .font(FontStyle.hallOfFame())
                    
                Spacer()
                
                Button("자동 등록") {
                    viewModel.automaticRegisterButtonTapped()
                }
            }
            .padding(.horizontal, 20)
            
            Text("마일리지 등록을 원하는 운동 기록을 선택해주세요!")
                .font(FontStyle.workoutSubtitle())
                .padding(.bottom, 20)
                .padding(.horizontal, 20)
        }
    }
}


private struct WorkoutScrollView: View {
    @Binding var viewModel: WorkoutListViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(viewModel.workouts) { workout in
                    WorkoutCell(workout: workout) {
                        viewModel.workoutCellTapped(workout: workout)
                    }
                    .padding(.bottom, 15)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

private struct WorkoutLoadingView: View {
    var body: some View {
        Group {
            Spacer()
            ProgressView()
                .progressViewStyle(.circular)
            Spacer()
        }
    }
}


private struct WorkoutEmptyView: View {
    let viewModel: WorkoutListViewModel
    
    var body: some View {
        Group {
            Spacer()
            Text("Fitness에 저장된 달리기 기록이 있으면\n자동으로 연동됩니다.")
                .foregroundStyle(.placeholder1)
            Button("기록이 있으나\n나타나지 않을 경우") {
                viewModel.workoutNotVisibleButtonTapped()
            }
            Spacer()
        }
        .font(FontStyle.workoutSubtitle())
        .multilineTextAlignment(.center)
    }
}

#Preview {
    WorkoutListView()
}
