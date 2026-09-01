//
//  MyPageView.swift
//  Run Mile
//
//  Created by 문인범 on 4/16/25.
//

import SwiftUI


struct MyPageView: View {
    @State private var viewModel: MyPageViewModel
    
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Hall of Fame Hero Card
                HallOfFameCard {
                    viewModel.HOFButtonTapped()
                }
                
                // MARK: - Menu Grid
                VStack(spacing: 16) {
                    ForEach(MyPageViewModel.MyPageStatus.allCases, id: \.self) { status in
                        MenuCard(
                            icon: status.icon,
                            color: status.color,
                            title: status.cellName,
                            subtitle: status.subtitle,
                            action: {
                                viewModel.myPageCellTapped(status)
                            }
                        )
                    }
                }
            }
            .padding(20)
        }
        .background(RunMileColor.background)
        .sheet(isPresented: $viewModel.isContactPresented) {
            ContactView()
        }
    }
}


// MARK: - Subviews

private struct HallOfFameCard: View {
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            hallOfFameBody
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var hallOfFameBody: some View {
        HStack(spacing: 16) {
            trophyBadge(size: 72)

            VStack(alignment: .leading, spacing: 8) {
                legendaryLabel(foreground: RunMileColor.primaryText)

                Text("명예의 전당")
                    .font(.title2.weight(.heavy))
                    .foregroundStyle(RunMileColor.foreground)

                Text("목표를 달성한 신발들을 확인해보세요")
                    .font(.subheadline)
                    .foregroundStyle(RunMileColor.mutedForeground)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(RunMileColor.mutedForeground)
        }
        .padding(16)
        .runMileBrutalCard()
    }

    private func legendaryLabel(foreground: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
            Text("LEGENDARY")
                .tracking(1)
        }
        .font(.caption.weight(.bold))
        .foregroundStyle(foreground)
    }

    private func trophyBadge(size: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: RunMileRadius.input, style: .continuous)
            .fill(RunMileColor.secondary)
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: "trophy.fill")
                    .font(.system(size: size * 0.42, weight: .bold))
                    .foregroundStyle(RunMileColor.secondaryForeground)
            }
            .overlay {
                RoundedRectangle(cornerRadius: RunMileRadius.input, style: .continuous)
                    .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
            }
    }
}

private struct MenuCard: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: RunMileRadius.input, style: .continuous)
                    .fill(color)
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundStyle(icon == "info.circle.fill" ? RunMileColor.primaryForeground : RunMileColor.accentForeground)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: RunMileRadius.input, style: .continuous)
                            .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                    }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(RunMileColor.foreground)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(RunMileColor.mutedForeground)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundStyle(RunMileColor.mutedForeground)
            }
            .padding(16)
            .runMileBrutalCard()
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Custom Button Style for Bouncy Effect
private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.snappy(duration: 0.2), value: configuration.isPressed)
    }
}


#if DEBUG
#Preview {
    MyPageView(viewModel: PreviewDIContainer().makeMyPageViewModel())
}
#endif
