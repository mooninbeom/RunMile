import SwiftUI


struct AppUpdateDetailSheet: View {
    @State private var viewModel: AppUpdateDetailSheetViewModel

    init(viewModel: AppUpdateDetailSheetViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ViewThatFits(in: .vertical) {
            content

            ScrollView(showsIndicators: false) {
                content
            }
            .frame(maxHeight: RunMileSize.appUpdateSheetMaxHeight)
        }
        .background(RunMileColor.background)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: RunMileRadius.sheet,
                topTrailingRadius: RunMileRadius.sheet
            )
        )
        .overlay {
            UnevenRoundedRectangle(
                topLeadingRadius: RunMileRadius.sheet,
                topTrailingRadius: RunMileRadius.sheet
            )
            .stroke(RunMileColor.border, lineWidth: RunMileStroke.strong)
        }
    }

    private var content: some View {
        VStack(spacing: RunMileSpacing.large) {
            introduction
            highlights
            actions
        }
        .padding(.horizontal, RunMileSpacing.screenHorizontal)
        .padding(.top, RunMileSpacing.xLarge)
        .padding(.bottom, RunMileSpacing.xLarge)
    }

    private var introduction: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: RunMileSpacing.regular) {
                introductionCopy

                Spacer(minLength: 0)

                updateIcon
            }

            VStack(alignment: .leading, spacing: RunMileSpacing.regular) {
                updateIcon
                introductionCopy
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var introductionCopy: some View {
        VStack(alignment: .leading, spacing: RunMileSpacing.medium) {
            Text("이번 업데이트를\n확인해 보세요")
                .font(.largeTitle.weight(.black))
                .foregroundStyle(RunMileColor.foreground)
                .fixedSize(horizontal: false, vertical: true)

            Text(viewModel.info.summary)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(RunMileColor.mutedForeground)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var updateIcon: some View {
        AppUpdateIconView(
            size: RunMileSize.appUpdateSheetIcon,
            symbolSize: RunMileSize.appUpdateSheetSymbol,
            shadowOffset: RunMileShadow.offset
        )
    }

    private var highlights: some View {
        VStack(alignment: .leading, spacing: RunMileSpacing.regular) {
            ForEach(viewModel.info.highlights.indices, id: \.self) { index in
                HStack(alignment: .firstTextBaseline, spacing: RunMileSpacing.medium) {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.black))
                        .foregroundStyle(RunMileColor.primary)
                        .frame(width: RunMileSize.iconSmall)

                    Text(viewModel.info.highlights[index])
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(RunMileColor.foreground)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(RunMileSpacing.regular)
        .runMileBrutalCard()
    }

    private var actions: some View {
        VStack(spacing: RunMileSpacing.medium) {
            Button(action: viewModel.updateButtonTapped) {
                HStack(spacing: RunMileSpacing.small) {
                    Text("App Store에서 업데이트")
                    Image(systemName: "arrow.up.right")
                }
                .frame(maxWidth: .infinity)
            }
            .runMilePrimaryButton()

            Button(action: viewModel.laterButtonTapped) {
                Text("나중에")
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(RunMileColor.foreground)
                    .frame(minHeight: RunMileSize.compactButtonHeight)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
    }
}


#if DEBUG
#Preview("App Update Detail Sheet") {
    ZStack(alignment: .bottom) {
        RunMileColor.muted
            .ignoresSafeArea()

        AppUpdateDetailSheet(
            viewModel: PreviewDIContainer().makeAppUpdateDetailSheetViewModel(
                info: .preview,
                dismissAction: {}
            )
        )
    }
    .ignoresSafeArea(edges: .bottom)
}
#endif
