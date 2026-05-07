//
//  WorkoutCell.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import SwiftUI


struct WorkoutCell: View {
    let workout: Workout
    
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    /// Distance
                    Text("\(workout.calculatedDistance)km")
                        .font(FontStyle.cellTitle())
                        .foregroundStyle(RunMileColor.foreground)

                    /// Date
                    Text(workout.date.workoutFormatDate)
                        .font(FontStyle.cellSubtitle())
                        .foregroundStyle(RunMileColor.mutedForeground)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 20))
                    .foregroundStyle(RunMileColor.mutedForeground)
            }
            .padding(.horizontal, 15)
            .frame(height: 80)
            .runMileBrutalCard()
        }
    }
}
