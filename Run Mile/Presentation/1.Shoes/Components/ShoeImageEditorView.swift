import SwiftUI


struct ShoeImageEditorView: View {
    let imageData: Data
    let isBackgroundRemoved: Bool
    let isProcessing: Bool
    let onChangePhoto: () -> Void
    let onRemoveBackground: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: RunMileSpacing.small) {
            Label("신발 사진", systemImage: "photo.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(RunMileColor.mutedForeground)

            HStack(spacing: RunMileSpacing.regular) {
                shoeImageView
                actionView
            }
            .padding(RunMileSpacing.regular)
            .runMileBrutalCard(
                cornerRadius: RunMileRadius.image,
                fill: RunMileColor.surfaceElevated
            )
        }
    }

    private var shoeImageView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                .fill(RunMileColor.muted)

            if let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(RunMileSpacing.small)
            } else {
                Image(systemName: "shoe.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(RunMileColor.mutedForeground)
                    .padding(RunMileSpacing.xLarge)
            }

            if isProcessing {
                ProgressView()
                    .tint(RunMileColor.foreground)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(RunMileColor.background.opacity(0.72))
            }
        }
        .frame(width: RunMileSize.shoesThumbnail, height: RunMileSize.shoesThumbnail)
        .clipShape(RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
        }
        .accessibilityLabel("현재 신발 사진")
    }

    private var actionView: some View {
        VStack(alignment: .leading, spacing: RunMileSpacing.medium) {
            VStack(alignment: .leading, spacing: RunMileSpacing.xSmall) {
                Text("대표 사진")
                    .font(.headline.weight(.black))
                    .foregroundStyle(RunMileColor.foreground)

                Text("신발 전체가 보이도록 촬영해주세요.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(RunMileColor.mutedForeground)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: RunMileSpacing.small) {
                imageActionButton(
                    configuration: .changePhoto,
                    action: onChangePhoto
                )

                imageActionButton(
                    configuration: isBackgroundRemoved ? .restoreBackground : .removeBackground,
                    action: onRemoveBackground
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func imageActionButton(
        configuration: ImageActionConfiguration,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(configuration.title, systemImage: configuration.symbolName)
                .font(.caption.weight(.black))
                .foregroundStyle(RunMileColor.foreground)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity)
                .frame(minHeight: RunMileSize.compactButtonHeight)
                .background {
                    RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                        .fill(configuration.backgroundColor)
                        .shadow(
                            color: RunMileColor.hardShadow,
                            radius: 0,
                            x: RunMileStroke.border,
                            y: RunMileStroke.border
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                }
        }
        .buttonStyle(.plain)
        .disabled(isProcessing)
    }
}


private struct ImageActionConfiguration {
    let title: String
    let symbolName: String
    let backgroundColor: Color

    static let changePhoto = ImageActionConfiguration(
        title: "사진 변경",
        symbolName: "camera.fill",
        backgroundColor: RunMileColor.secondary
    )

    static let removeBackground = ImageActionConfiguration(
        title: "배경 제거",
        symbolName: "eraser.fill",
        backgroundColor: RunMileColor.surface
    )

    static let restoreBackground = ImageActionConfiguration(
        title: "원본 복원",
        symbolName: "arrow.uturn.backward",
        backgroundColor: RunMileColor.surface
    )
}


#if DEBUG
#Preview("신발 이미지 수정") {
    ShoeImageEditorView(
        imageData: Data(),
        isBackgroundRemoved: false,
        isProcessing: false,
        onChangePhoto: {},
        onRemoveBackground: {}
    )
    .padding(RunMileSpacing.screenHorizontal)
    .background(RunMileColor.background)
}
#endif
