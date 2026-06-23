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
    let registeredShoeName: String?
    let isHOFRestricted: Bool

    init(
        workout: Workout,
        registeredShoeName: String? = nil,
        isHOFRestricted: Bool = false
    ) {
        self.workout = workout
        self.registeredShoeName = registeredShoeName
        self.isHOFRestricted = isHOFRestricted
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(workout.date.koreanMonthDay)
                        .font(.caption.weight(.black))
                        .foregroundStyle(RunMileColor.primary)

                    Text("\(workout.calculatedDistance) km")
                        .font(.title2.weight(.black))
                        .foregroundStyle(RunMileColor.foreground)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                registrationBadge
            }

            HStack(spacing: 12) {
                metricLine

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.black))
                    .foregroundStyle(RunMileColor.mutedForeground)
            }
        }
        .padding(16)
        .runMileBrutalCard()
        .overlay {
            if isHOFRestricted {
                HOFRestrictedSideRailOverlay()
                    .allowsHitTesting(false)
            }
        }
    }

    private var metricLine: some View {
        HStack(spacing: 10) {
            Label(workout.avgPace, systemImage: "stopwatch")
            Label(workout.time.toKoreanHourMinuteDuration(), systemImage: "clock")
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(RunMileColor.mutedForeground)
        .lineLimit(1)
    }

    private var registrationBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: registeredShoeName == nil ? "minus.circle" : "shoe.fill")
                .font(.caption.weight(.black))

            Text(registeredShoeName ?? "미등록")
                .font(.caption.weight(.black))
                .lineLimit(1)
        }
        .foregroundStyle(registeredShoeName == nil ? RunMileColor.primary : RunMileColor.secondaryForeground)
        .padding(.horizontal, 10)
        .frame(height: 30)
        .frame(maxWidth: 132, alignment: .leading)
        .background(registeredShoeName == nil ? RunMileColor.card : RunMileColor.secondary)
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                .stroke(registeredShoeName == nil ? RunMileColor.primary : RunMileColor.border, lineWidth: RunMileStroke.border)
        }
    }
}


private struct HOFRestrictedSideRailOverlay: View {
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 5) {
                Image(systemName: "lock.fill")
                    .font(.caption2.weight(.black))

                Text("HOF")
                    .font(.caption2.weight(.black))
                    .tracking(1)
            }
            .foregroundStyle(RunMileColor.secondaryForeground)
            .frame(width: 42)
            .frame(maxHeight: .infinity)
            .background(RunMileColor.secondary.opacity(0.98))
            .overlay(alignment: .trailing) {
                Rectangle()
                    .fill(RunMileColor.border)
                    .frame(width: RunMileStroke.border)
            }

            Spacer()
        }
        .clipShape(RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous))
    }
}
