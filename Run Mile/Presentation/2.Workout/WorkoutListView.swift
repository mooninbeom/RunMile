//
//  WorkoutListView.swift
//  Run Mile
//
//  Created by 문인범 on 4/16/25.
//

import SwiftUI


struct WorkoutListView: View {
    @State private var viewModel: WorkoutListViewModel
    
    init(viewModel: WorkoutListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            RunMileColor.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView

                contentView
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .bottom) {
            if viewModel.viewStatus == .selection {
                selectionFloatingPill
            }
        }
        .task {
            await viewModel.onAppear()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack(alignment: .center, spacing: 16) {
            Text("운동 기록")
                .font(.largeTitle.weight(.black))
                .foregroundStyle(RunMileColor.foreground)

            Spacer(minLength: 12)

            topActionControls
        }
        .padding(.horizontal, RunMileSpacing.screenHorizontal)
        .padding(.top, RunMileSpacing.xLarge)
        .padding(.bottom, RunMileSpacing.section)
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.viewStatus {
        case .loading:
            ProgressView()
                .progressViewStyle(.circular)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .empty:
            workoutEmptyView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .none, .selection:
            workoutScrollView
        }
    }

    private var topActionControls: some View {
        HStack(spacing: 0) {
            if viewModel.viewStatus != .selection {
                Button {
                    viewModel.automaticRegisterButtonTapped()
                } label: {
                    Image(systemName: "bolt.fill")
                        .font(.title3.weight(.black))
                        .foregroundStyle(RunMileColor.secondaryForeground)
                        .frame(width: 46, height: 38)
                        .background(RunMileColor.secondary)
                }
                .buttonStyle(.plain)

                Rectangle()
                    .fill(RunMileColor.border)
                    .frame(width: RunMileStroke.hairline, height: 30)
            }

            Button {
                withAnimation(.snappy) {
                    if viewModel.viewStatus == .selection {
                        viewModel.cancelButtonTapped()
                    } else {
                        viewModel.selectionButtonTapped()
                    }
                }
            } label: {
                Text(viewModel.viewStatus == .selection ? "취소" : "선택")
                    .font(.headline.weight(.black))
                    .foregroundStyle(RunMileColor.primary)
                    .frame(minWidth: 62)
                    .frame(height: 38)
            }
            .buttonStyle(.plain)
        }
        .fixedSize()
        .background {
            RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                .fill(RunMileColor.card)
                .shadow(color: RunMileColor.border, radius: 0, x: 2, y: 2)
        }
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
        }
    }

    private var workoutScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(viewModel.dateHeaders.indices, id: \.self) { index in
                    Section {
                        VStack(spacing: 12) {
                            ForEach(viewModel.workouts[index]) { workout in
                                Button {
                                    viewModel.workoutCellTapped(workout: workout)
                                } label: {
                                    HStack(spacing: 12) {
                                        if viewModel.viewStatus == .selection {
                                            Image(systemName: viewModel.isSelectedWorkout(workout) ? "checkmark.circle.fill" : "circle")
                                                .font(.title2)
                                                .foregroundStyle(viewModel.isSelectedWorkout(workout) ? RunMileColor.accent : RunMileColor.mutedForeground)
                                        }
                                        
                                        WorkoutHistoryCell(
                                            workout: workout,
                                            registeredShoeName: viewModel.registeredShoeName(for: workout)
                                        )
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    } header: {
                        HStack {
                            Text(viewModel.dateHeaders[index])
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(RunMileColor.foreground)
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
                .foregroundStyle(RunMileColor.primaryForeground)
            
            Rectangle()
                .fill(RunMileColor.primaryForeground.opacity(0.35))
                .frame(width: 1, height: 16)
            
            Button {
                viewModel.saveSelectedWorkoutsButtonTapped()
            } label: {
                Text("저장")
                    .fontWeight(.bold)
                    .foregroundStyle(RunMileColor.primaryForeground)
            }
            .disabled(viewModel.selectedWorkout.isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                .fill(RunMileColor.primary)
                .shadow(color: RunMileColor.border, radius: 0, x: 4, y: 4)
        }
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
        }
        .padding(.bottom, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private var workoutEmptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.run.square.stack")
                .font(.system(size: 60))
                .foregroundStyle(RunMileColor.foreground)
            Text("아직 기록된 운동이 없습니다.\nApple Watch나 iPhone으로 달리기를 시작해보세요!")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundStyle(RunMileColor.mutedForeground)
            Button("데이터 새로고침") {
                Task {
                    await viewModel.refresh()
                }
            }
            .buttonStyle(.plain)
            .runMileSecondaryButton()
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        WorkoutListView(viewModel: AppDIContainer().makeWorkoutListViewModel())
    }
}
