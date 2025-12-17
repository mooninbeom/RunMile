//
//  WorkoutHistoryCell.swift
//  Run Mile
//
//  Created by 문인범 on 5/18/25.
//

import SwiftUI
import HealthKit

struct WorkoutHistoryCell: View {
    let workout: Workout
    
    var body: some View {
        HStack(spacing: 16) {
            // Date Box
            VStack {
                Text(workout.date, format: .dateTime.month(.abbreviated))
                    .font(.caption)
                    .foregroundStyle(.red)
                    .textCase(.uppercase)
                Text(workout.date, format: .dateTime.day())
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .frame(width: 50)
            .padding(.vertical, 8)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(workout.calculatedDistance) km")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 8) {
                    Label(workout.avgPace, systemImage: "stopwatch")
                    Label("\(Int(workout.time / 60))분", systemImage: "clock")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

