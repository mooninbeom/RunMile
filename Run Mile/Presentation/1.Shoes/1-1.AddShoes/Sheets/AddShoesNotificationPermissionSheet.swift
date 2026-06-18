//
//  AddShoesNotificationPermissionSheet.swift
//  Run Mile
//
//  Created by Codex on 6/17/26.
//

import SwiftUI


struct AddShoesNotificationPermissionSheetContainer: View {
    @State private var viewModel: AddShoesNotificationPermissionSheetViewModel

    init(viewModel: AddShoesNotificationPermissionSheetViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        AddShoesNotificationPermissionSheet(
            onConfirm: viewModel.confirmButtonTapped
        )
        .disabled(viewModel.isRequestingNotificationPermission)
    }
}


struct AddShoesNotificationPermissionSheet: View {
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            Capsule()
                .fill(RunMileColor.border.opacity(0.28))
                .frame(width: 54, height: 6)

            VStack(alignment: .leading, spacing: 14) {
                Text("신발 등록 완료")
                    .font(.caption.weight(.black))
                    .tracking(1.4)
                    .foregroundStyle(RunMileColor.primary)

                Text("러닝 후 기록을\n놓치지 않게 알려드릴게요")
                    .font(.system(size: 29, weight: .black))
                    .foregroundStyle(RunMileColor.foreground)
                    .lineSpacing(-1)
                    .fixedSize(horizontal: false, vertical: true)

                Text("운동이 끝나면 방금 등록한 신발에 마일리지를 기록할 수 있도록 알려드려요.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(RunMileColor.mutedForeground)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 10) {
                NotificationBenefitRow(
                    icon: "shoe.2.fill",
                    title: "기록 누락 방지",
                    description: "러닝 후 신발 연결을 놓치지 않게 도와줘요.",
                    tint: RunMileColor.primary
                )

                NotificationBenefitRow(
                    icon: "bolt.fill",
                    title: "마일리지 확인",
                    description: "거리 기록이 쌓이면 바로 확인할 수 있어요.",
                    tint: RunMileColor.secondary
                )

                NotificationBenefitRow(
                    icon: "bell.badge.fill",
                    title: "필요한 알림만",
                    description: "러닝 기록 관리에 필요한 알림만 사용해요.",
                    tint: RunMileColor.accent
                )
            }

            Button(action: onConfirm) {
                Text("확인")
                    .frame(maxWidth: .infinity)
            }
            .runMilePrimaryButton()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 30)
        .frame(maxWidth: .infinity)
        .background(RunMileColor.background)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.strong)
        }
    }
}


private struct NotificationBenefitRow: View {
    let icon: String
    let title: String
    let description: String
    let tint: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(RunMileColor.muted, in: RoundedRectangle(cornerRadius: RunMileRadius.small, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: RunMileRadius.small, style: .continuous)
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(RunMileColor.foreground)

                Text(description)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(RunMileColor.mutedForeground)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .background(RunMileColor.card)
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
        }
    }
}


#if DEBUG
#Preview("Add Shoes Notification Permission Sheet") {
    ZStack {
        RunMileColor.background
            .ignoresSafeArea()

        VStack {
            Spacer()

            AddShoesNotificationPermissionSheetContainer(
                viewModel: PreviewDIContainer().makeAddShoesNotificationPermissionSheetViewModel()
            )
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
#endif
