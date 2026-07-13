import SwiftUI


struct AppUpdateIconView: View {
    let size: CGFloat
    let symbolSize: CGFloat
    let shadowOffset: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: RunMileRadius.small, style: .continuous)
                .fill(RunMileColor.border)
                .offset(x: shadowOffset, y: shadowOffset)

            RoundedRectangle(cornerRadius: RunMileRadius.small, style: .continuous)
                .fill(RunMileColor.primary)
                .overlay {
                    RoundedRectangle(cornerRadius: RunMileRadius.small, style: .continuous)
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                }

            Image(systemName: "arrow.down")
                .font(.system(size: symbolSize, weight: .black))
                .foregroundStyle(RunMileColor.primaryForeground)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}


#if DEBUG
#Preview("App Update Icon") {
    AppUpdateIconView(
        size: RunMileSize.appUpdateSheetIcon,
        symbolSize: RunMileSize.appUpdateSheetSymbol,
        shadowOffset: RunMileShadow.offset
    )
    .padding(RunMileSpacing.xLarge)
    .background(RunMileColor.secondary)
}
#endif
