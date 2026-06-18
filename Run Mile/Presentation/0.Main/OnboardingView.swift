//
//  OnboardingView.swift
//  Run Mile
//
//  Created by Codex on 6/16/26.
//

import SwiftUI


struct OnboardingGateView<Content: View>: View {
    @AppStorage(UserDefaults.Key.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @State private var onboardingViewModel: OnboardingViewModel
    @State private var hasCompletedDebugOnboardingSession = false

    private let content: () -> Content

    init(
        viewModel: OnboardingViewModel,
        @ViewBuilder content: @escaping () -> Content
    ) {
        _onboardingViewModel = State(initialValue: viewModel)
        self.content = content
    }

    var body: some View {
        Group {
            #if DEBUG
            if hasCompletedDebugOnboardingSession {
                content()
            } else {
                onboardingFlow
            }
            #else
            if hasCompletedOnboarding {
                content()
            } else {
                onboardingFlow
            }
            #endif
        }
    }

    private var onboardingFlow: some View {
        OnboardingView(viewModel: onboardingViewModel) {
            withAnimation(.easeInOut(duration: 0.25)) {
                hasCompletedOnboarding = true
                hasCompletedDebugOnboardingSession = true
            }
        }
    }
}


struct OnboardingView: View {
    @State private var viewModel: OnboardingViewModel

    private let pages = OnboardingPage.samplePages
    private let onFinish: () -> Void

    init(
        viewModel: OnboardingViewModel,
        onFinish: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onFinish = onFinish
    }

    var body: some View {
        VStack(spacing: 0) {
            OnboardingPageView(page: pages[viewModel.currentIndex])
                .id(viewModel.currentIndex)
                .padding(.horizontal, RunMileSpacing.screenHorizontal)

            bottomBar
                .padding(.horizontal, RunMileSpacing.screenHorizontal)
                .padding(.bottom, 18)
        }
        .background(RunMileColor.background)
    }

    private var bottomBar: some View {
        VStack(spacing: 18) {
            HStack(spacing: 8) {
                ForEach(pages.indices, id: \.self) { index in
                    Capsule()
                        .fill(index == viewModel.currentIndex ? RunMileColor.primary : RunMileColor.muted)
                        .frame(width: index == viewModel.currentIndex ? 34 : 10, height: 10)
                        .overlay {
                            Capsule()
                                .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
                        }
                        .animation(.spring(response: 0.25, dampingFraction: 0.85), value: viewModel.currentIndex)
                }
            }

            Button(action: primaryButtonTapped) {
                Text(pages[viewModel.currentIndex].buttonTitle)
                    .frame(maxWidth: .infinity)
            }
            .runMilePrimaryButton()
            .disabled(viewModel.isRequestingHealthAuthorization)
        }
    }

    private func primaryButtonTapped() {
        Task {
            await viewModel.primaryButtonTapped(
                pageCount: pages.count,
                onFinish: onFinish
            )
        }
    }
}


private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                hero

                VStack(alignment: .leading, spacing: 8) {
                    Text(page.kicker)
                        .font(.caption)
                        .fontWeight(.black)
                        .tracking(1.6)
                        .foregroundStyle(page.accent)

                    Text(page.title)
                        .font(.system(size: 36, weight: .black, design: .default))
                        .foregroundStyle(RunMileColor.foreground)
                        .lineSpacing(-1)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(page.subtitle)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(RunMileColor.mutedForeground)
                        .fixedSize(horizontal: false, vertical: true)
                }

                OnboardingContentCard(page: page)

                Spacer(minLength: 24)
            }
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
    }

    private var hero: some View {
        ZStack {
            OnboardingHeroBackground()

            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous))
                .padding(18)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 260)
    }
}


private struct OnboardingHeroBackground: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                .fill(RunMileColor.secondary)
                .offset(x: 8, y: 8)

            RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                .fill(RunMileColor.card)
                .overlay {
                    RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.strong)
                }
        }
    }
}


private struct OnboardingContentCard: View {
    let page: OnboardingPage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(page.items) { item in
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: item.symbolName)
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(item.tint)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.title)
                            .font(.subheadline)
                            .fontWeight(.black)
                            .foregroundStyle(RunMileColor.foreground)

                        Text(item.description)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(RunMileColor.mutedForeground)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }
                .padding(10)
                .background(RunMileColor.background)
                .overlay {
                    RoundedRectangle(cornerRadius: RunMileRadius.small, style: .continuous)
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
                }
            }
        }
        .padding(12)
        .runMileBrutalCard()
    }
}


private struct OnboardingPage: Identifiable {
    let id = UUID()
    let kicker: String
    let title: String
    let subtitle: String
    let buttonTitle: String
    let accent: Color
    let imageName: String
    let items: [OnboardingItem]
}


private struct OnboardingItem: Identifiable {
    let id = UUID()
    let symbolName: String
    let title: String
    let description: String
    let tint: Color
}


private extension OnboardingPage {
    static let samplePages: [OnboardingPage] = [
        OnboardingPage(
            kicker: "WELCOME",
            title: "러닝화 수명,\n거리로 관리",
            subtitle: "신발마다 누적 km를 쌓아 교체 시점을 확인해요.",
            buttonTitle: "시작하기",
            accent: RunMileColor.primary,
            imageName: "Onboarding_Mileage",
            items: [
                OnboardingItem(symbolName: "shoe.2.fill", title: "누적 거리", description: "러닝화별 사용 거리를 기록합니다.", tint: RunMileColor.primary),
                OnboardingItem(symbolName: "flag.checkered", title: "목표 설정", description: "교체 기준 km를 정해요.", tint: RunMileColor.foreground)
            ]
        ),
        OnboardingPage(
            kicker: "HEALTH",
            title: "러닝 기록과\n분석 데이터를 가져올게요",
            subtitle: "거리, 시간, 페이스부터 심박과 러닝 자세 지표까지 운동 분석에 필요한 데이터만 사용해요.",
            buttonTitle: "건강 데이터 연결",
            accent: RunMileColor.accent,
            imageName: "Onboarding_Health",
            items: [
                OnboardingItem(symbolName: "figure.run", title: "러닝만 사용", description: "걷기나 다른 운동은 제외하고 러닝 기록만 가져와요.", tint: RunMileColor.accent),
                OnboardingItem(symbolName: "lock.shield.fill", title: "상세 분석 지표", description: "심박, 파워, 보폭, 수직 진폭 등 러닝 분석에 필요한 항목을 사용해요.", tint: RunMileColor.primary)
            ]
        ),
        OnboardingPage(
            kicker: "READY",
            title: "신발을 연결하면\n자동으로 쌓여요",
            subtitle: "운동 후 신발만 선택하면 누적 거리가 기록돼요.",
            buttonTitle: "시작하기",
            accent: RunMileColor.primary,
            imageName: "Onboarding_Ready",
            items: [
                OnboardingItem(symbolName: "shoe.2.fill", title: "신발 연결", description: "운동 기록에 러닝화를 연결해요.", tint: RunMileColor.primary),
                OnboardingItem(symbolName: "bolt.fill", title: "자동 누적", description: "연결한 신발에 km가 쌓여요.", tint: RunMileColor.secondary)
            ]
        )
    ]
}


#Preview("Run Mile Onboarding") {
    OnboardingView(
        viewModel: PreviewDIContainer().makeOnboardingViewModel(),
        onFinish: {}
    )
}
