//
//  ShoesWorkoutManagementSheet.swift
//  Run Mile
//
//  Created by Codex on 5/8/26.
//

import SwiftUI


struct ShoesWorkoutManagementSheet: View {
    let workouts: [Workout]
    @Binding var selectedWorkoutIDs: Set<UUID>
    let onCancel: () -> Void
    let onRemove: () -> Void
    
    private var totalDistance: String {
        let kilometer = workouts.reduce(0) { $0 + $1.distance } / 1000
        return String(format: "%.2fkm", kilometer)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerView
                contentView
            }
            .safeAreaInset(edge: .bottom) {
                removeButtonContainer
            }
            .background(RunMileColor.background)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기", action: onCancel)
                        .foregroundStyle(RunMileColor.primary)
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("연결된 운동")
                .font(.title2.weight(.black))
                .foregroundStyle(RunMileColor.foreground)
            
            Text("\(workouts.count)개 운동 · \(totalDistance)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(RunMileColor.mutedForeground)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
    }
    
    @ViewBuilder
    private var contentView: some View {
        if workouts.isEmpty {
            emptyStateView
        } else {
            workoutListView
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "link.badge.plus")
                .font(.system(size: 38, weight: .bold))
                .foregroundStyle(RunMileColor.mutedForeground)
            
            Text("연결된 운동이 없습니다.")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(RunMileColor.mutedForeground)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var workoutListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(workouts) { workout in
                    LinkedWorkoutRow(
                        workout: workout,
                        isSelected: selectedWorkoutIDs.contains(workout.id),
                        onTap: { toggleWorkout(workout.id) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    private var removeButtonContainer: some View {
        VStack(spacing: 10) {
            Button(action: onRemove) {
                Text(selectedWorkoutIDs.isEmpty ? "선택한 운동 연결 해제" : "\(selectedWorkoutIDs.count)개 운동 연결 해제")
                    .runMilePrimaryButton(isEnabled: !selectedWorkoutIDs.isEmpty)
            }
            .disabled(selectedWorkoutIDs.isEmpty)
        }
        .padding(20)
        .background(RunMileColor.background)
    }
    
    private func toggleWorkout(_ id: UUID) {
        if selectedWorkoutIDs.contains(id) {
            selectedWorkoutIDs.remove(id)
        } else {
            selectedWorkoutIDs.insert(id)
        }
    }
}


private struct LinkedWorkoutRow: View {
    let workout: Workout
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "minus.circle")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(isSelected ? RunMileColor.primary : RunMileColor.mutedForeground)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(workout.date.koreanMonthDay)
                        .font(.caption.weight(.black))
                        .foregroundStyle(RunMileColor.primary)
                    
                    Text("\(workout.calculatedDistance) km")
                        .font(.title3.weight(.black))
                        .foregroundStyle(RunMileColor.foreground)
                    
                    HStack(spacing: 10) {
                        Label(workout.avgPace, systemImage: "stopwatch")
                        Label(workout.time.toKoreanHourMinuteDuration(), systemImage: "clock")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(RunMileColor.mutedForeground)
                }
                
                Spacer()
                
                Text("연결 해제")
                    .font(.caption.weight(.black))
                    .foregroundStyle(RunMileColor.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .overlay {
                        RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                            .stroke(RunMileColor.primary, lineWidth: RunMileStroke.border)
                    }
            }
            .padding(16)
            .runMileBrutalCard()
        }
        .buttonStyle(.plain)
    }
}
