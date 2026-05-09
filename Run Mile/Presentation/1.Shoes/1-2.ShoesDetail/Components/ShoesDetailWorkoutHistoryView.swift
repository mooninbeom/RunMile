//
//  ShoesDetailWorkoutHistoryView.swift
//  Run Mile
//
//  Created by Codex on 5/8/26.
//

import SwiftUI


struct ShoesDetailWorkoutHistoryView: View {
    let workouts: [Workout]
    let shoesName: String
    let onWorkoutTap: (Workout) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("최근 활동")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(RunMileColor.foreground)
                .padding(.horizontal)
            
            if workouts.isEmpty {
                emptyStateView
            } else {
                workoutListView
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.run.circle")
                .font(.system(size: 40))
                .foregroundStyle(RunMileColor.foreground)
            
            Text("아직 기록된 운동이 없습니다.")
                .font(.subheadline)
                .foregroundStyle(RunMileColor.mutedForeground)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background {
            RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                .fill(RunMileColor.muted)
        }
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
        }
        .padding(.horizontal)
    }
    
    private var workoutListView: some View {
        LazyVStack(spacing: 12) {
            ForEach(workouts) { workout in
                WorkoutHistoryCell(workout: workout, registeredShoeName: shoesName)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onWorkoutTap(workout)
                    }
            }
        }
        .padding(.horizontal)
    }
}
