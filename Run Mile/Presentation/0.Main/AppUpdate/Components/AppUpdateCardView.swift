import SwiftUI


struct AppUpdateCardView: View {
    let info: AppUpdatePresentationInfo
    let onOpen: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: RunMileSpacing.medium) {
            header

            Button(action: onOpen) {
                VStack(alignment: .leading, spacing: RunMileSpacing.medium) {
                    message

                    Rectangle()
                        .fill(RunMileColor.border)
                        .frame(height: RunMileStroke.hairline)

                    HStack(spacing: RunMileSpacing.small) {
                        Text(info.versionText)
                            .font(.caption.weight(.black))

                        Spacer(minLength: RunMileSpacing.small)

                        Text("변경 내용 보기")
                            .font(.subheadline.weight(.black))

                        Image(systemName: "arrow.right")
                            .font(.caption.weight(.black))
                    }
                    .foregroundStyle(RunMileColor.secondaryForeground)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(info.cardAccessibilityLabel)
            .accessibilityHint("변경 내용을 확인합니다.")
        }
        .padding(RunMileSpacing.regular)
        .runMileBrutalCard(fill: RunMileColor.secondary)
    }

    private var header: some View {
        HStack(spacing: RunMileSpacing.small) {
            Text("UPDATE")
                .font(.caption.weight(.black))
                .tracking(RunMileTracking.kicker)

            Spacer(minLength: 0)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.black))
                    .frame(width: RunMileSize.compactButtonHeight, height: RunMileSize.compactButtonHeight)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("업데이트 안내 닫기")
        }
        .foregroundStyle(RunMileColor.secondaryForeground)
    }

    private var message: some View {
        HStack(alignment: .center, spacing: RunMileSpacing.regular) {
            VStack(alignment: .leading, spacing: RunMileSpacing.small) {
                Text("새 버전이 도착했어요")
                    .font(.title3.weight(.black))
                    .foregroundStyle(RunMileColor.secondaryForeground)
                    .fixedSize(horizontal: false, vertical: true)

                Text(info.summary)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(RunMileColor.mutedForeground)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            AppUpdateIconView(
                size: RunMileSize.appUpdateCardIcon,
                symbolSize: RunMileSize.appUpdateCardSymbol,
                shadowOffset: RunMileShadow.compactOffset
            )
        }
    }
}


#if DEBUG
#Preview("App Update Card") {
    AppUpdateCardView(
        info: .preview,
        onOpen: {},
        onDismiss: {}
    )
    .padding(RunMileSpacing.screenHorizontal)
    .background(RunMileColor.background)
}
#endif
