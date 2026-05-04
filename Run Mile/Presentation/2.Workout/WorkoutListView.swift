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
//            workoutDataRepository: DebugingWorkoutDataRepository(),
            shoesDataRepository: ShoesDataRepositoryImpl()
        )
    )
    
    var body: some View {
        ZStack {
            Color(uiColor: .secondarySystemBackground)
                .ignoresSafeArea()
            
            switch viewModel.viewStatus {
            case .loading:
                ProgressView()
                    .progressViewStyle(.circular)
            case .empty:
                workoutEmptyView
            case .none, .selection:
                workoutScrollView
            }
        }
        .navigationTitle("운동 기록")
        .toolbar {
            if viewModel.viewStatus != .selection {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.automaticRegisterButtonTapped()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(viewModel.viewStatus == .selection ? "취소" : "선택") {
                    withAnimation(.snappy) {
                        if viewModel.viewStatus == .selection {
                            viewModel.cancelButtonTapped()
                        } else {
                            viewModel.selectionButtonTapped()
                        }
                    }
                }
                .fontWeight(viewModel.viewStatus == .selection ? .regular : .semibold)
            }
        }
        .overlay(alignment: .bottom) {
            if viewModel.viewStatus == .selection {
                selectionFloatingPill
            }
        }
        .task {
            await viewModel.onAppear()
        }
        .refreshable {
            await viewModel.onAppear()
        }
    }
    
    // MARK: - Subviews
    
    private var workoutScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(viewModel.dateHeaders.indices, id: \.self) { index in
                    Section {
                        VStack(spacing: 12) {
                            ForEach(viewModel.workouts[index]) { workout in
                                if viewModel.viewStatus == .selection {
                                    Button {
                                        viewModel.workoutCellTapped(workout: workout)
                                    } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: viewModel.isSelectedWorkout(workout) ? "checkmark.circle.fill" : "circle")
                                                .font(.title2)
                                                .foregroundStyle(viewModel.isSelectedWorkout(workout) ? Color.blue : Color.gray)
                                            
                                            WorkoutHistoryCell(workout: workout)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    NavigationLink{
                                        WorkoutDetailView(viewModel: .init(useCase: DefaultWorkoutDetailUseCase(workoutRepository: WorkoutDataRepositoryImpl()), workout: workout))
                                    } label: {
                                        HStack(spacing: 12) {
                                            WorkoutHistoryCell(workout: workout)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    } header: {
                        HStack {
                            Text(viewModel.dateHeaders[index])
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                                .padding(.leading, 4)
                            Spacer()
                        }
                        .padding(.bottom, 8)
                        .padding(.top, 10)
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 60) // Space for floating pill
        }
    }
    
    private var selectionFloatingPill: some View {
        HStack {
            Text("\(viewModel.selectedWorkout.count)개 선택됨")
                .font(.subheadline)
                .foregroundStyle(.white)
            
            Rectangle()
                .fill(.white.opacity(0.3))
                .frame(width: 1, height: 16)
            
            Button {
                viewModel.saveSelectedWorkoutsButtonTapped()
            } label: {
                Text("저장")
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            .disabled(viewModel.selectedWorkout.isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.blue)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding(.bottom, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private var workoutEmptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.run.square.stack")
                .font(.system(size: 60))
                .foregroundStyle(.secondary.opacity(0.5))
            Text("아직 기록된 운동이 없습니다.\nApple Watch나 iPhone으로 달리기를 시작해보세요!")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("데이터 새로고침") {
                Task {
                    await viewModel.onAppear()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        WorkoutListView()
    }
}
