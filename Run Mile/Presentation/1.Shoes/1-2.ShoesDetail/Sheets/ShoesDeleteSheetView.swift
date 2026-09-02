//
//  ShoesDeleteSheetView.swift
//  Run Mile
//
//  Created by Codex on 5/8/26.
//

import SwiftUI


struct ShoesDeleteSheetView: View {
    let shoesName: String
    let workoutCount: Int
    let onCancel: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            messageView
            actionButtonsView
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(RunMileColor.sheetSurface)
        .presentationBackground(RunMileColor.sheetSurface)
    }
    
    private var messageView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "trash.fill")
                .font(.title.weight(.black))
                .foregroundStyle(RunMileColor.primaryText)
                .frame(width: 52, height: 52)
                .background(RunMileColor.muted, in: RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                }
            
            Text("신발을 삭제할까요?")
                .font(.title2.weight(.black))
                .foregroundStyle(RunMileColor.foreground)
            
            Text("\(shoesName)의 신발 정보가 삭제됩니다.\n연결된 \(workoutCount)개 운동 기록은 유지되고 신발 마일리지 반영만 해제됩니다.")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(RunMileColor.mutedForeground)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 12) {
            Button(action: onDelete) {
                Text("삭제하기")
                    .runMilePrimaryButton()
            }
            
            Button(action: onCancel) {
                Text("취소")
                    .runMileSecondaryButton()
            }
        }
    }
}
