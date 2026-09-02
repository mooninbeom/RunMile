//
//  ShoesDetailManagementSection.swift
//  Run Mile
//
//  Created by Codex on 5/8/26.
//

import SwiftUI


struct ShoesDetailManagementSection: View {
    let workoutCount: Int
    let currentMileageText: String
    let onEditInfoTap: () -> Void
    let onWorkoutManagementTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("신발 관리")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(RunMileColor.foreground)
            
            VStack(spacing: 0) {
                ShoesManagementActionRow(
                    title: "신발 정보 수정",
                    subtitle: "브랜드, 이름, 용도, 목표 마일리지",
                    icon: "pencil.line",
                    tint: RunMileColor.accent,
                    action: onEditInfoTap
                )
                
                RunMileDivider()
                
                ShoesManagementActionRow(
                    title: "연결된 운동 관리",
                    subtitle: "\(workoutCount)개 운동 · \(currentMileageText)km",
                    icon: "figure.run",
                    tint: RunMileColor.primary,
                    action: onWorkoutManagementTap
                )
            }
            .runMileBrutalCard()
        }
        .padding(.horizontal)
    }
}


struct ShoesDetailDangerSection: View {
    let onDeleteTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("기타 관리")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(RunMileColor.foreground)
            
            ShoesManagementActionRow(
                title: "신발 삭제",
                subtitle: "운동 기록은 유지하고 신발 연결만 해제",
                icon: "trash",
                tint: RunMileColor.primary,
                action: onDeleteTap
            )
            .runMileBrutalCard()
        }
        .padding(.horizontal)
    }
}


private struct ShoesManagementActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.headline.weight(.bold))
                    .frame(width: 36, height: 36)
                    .foregroundStyle(tint)
                    .background(RunMileColor.muted, in: RoundedRectangle(cornerRadius: RunMileRadius.small, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: RunMileRadius.small, style: .continuous)
                            .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(RunMileColor.foreground)
                    
                    Text(subtitle)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(RunMileColor.mutedForeground)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.black))
                    .foregroundStyle(RunMileColor.mutedForeground)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}


private struct RunMileDivider: View {
    var body: some View {
        Rectangle()
            .fill(RunMileColor.borderSubtle)
            .frame(height: 1)
            .padding(.leading, 66)
    }
}
