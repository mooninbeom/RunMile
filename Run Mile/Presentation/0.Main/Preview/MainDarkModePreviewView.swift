//
//  MainDarkModePreviewView.swift
//  Run Mile
//
//  Created by Codex on 8/30/26.
//

#if DEBUG
import SwiftUI
import UIKit


#Preview("Main Tabs · Light") {
    MainTabDarkModePreviewContainer()
        .preferredColorScheme(.light)
}


#Preview("Main Tabs · Dark") {
    MainTabDarkModePreviewContainer()
        .preferredColorScheme(.dark)
}


#Preview("Onboarding · Light") {
    OnboardingView(
        viewModel: PreviewDIContainer().makeOnboardingViewModel(),
        onFinish: {}
    )
    .preferredColorScheme(.light)
}


#Preview("Onboarding · Dark") {
    OnboardingView(
        viewModel: PreviewDIContainer().makeOnboardingViewModel(),
        onFinish: {}
    )
    .preferredColorScheme(.dark)
}


#Preview("App Update Detail · Light") {
    AppUpdateDetailDarkModePreviewContainer()
        .preferredColorScheme(.light)
}


#Preview("App Update Detail · Dark") {
    AppUpdateDetailDarkModePreviewContainer()
        .preferredColorScheme(.dark)
}


#Preview("Image Detail · Light") {
    NavigationStack {
        ImageDetailView(image: makePreviewImageData())
            .navigationTitle("신발 이미지")
            .navigationBarTitleDisplayMode(.inline)
    }
    .preferredColorScheme(.light)
}


#Preview("Image Detail · Dark") {
    NavigationStack {
        ImageDetailView(image: makePreviewImageData())
            .navigationTitle("신발 이미지")
            .navigationBarTitleDisplayMode(.inline)
    }
    .preferredColorScheme(.dark)
}


@MainActor
private struct MainTabDarkModePreviewContainer: View {
    @State private var selectedTab: NavigationCoordinator.TabStatus = .shoes

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ShoesListView(viewModel: PreviewDIContainer().makeShoesListViewModel())
            }
            .tag(NavigationCoordinator.TabStatus.shoes)
            .tabItem {
                Image(systemName: "shoe.2.fill")
                Text("신발")
            }

            NavigationStack {
                WorkoutListView(viewModel: PreviewDIContainer().makeWorkoutListViewModel())
            }
            .tag(NavigationCoordinator.TabStatus.workout)
            .tabItem {
                Image(systemName: "figure.run")
                Text("운동")
            }

            NavigationStack {
                MyPageView(viewModel: PreviewDIContainer().makeMyPageViewModel())
            }
            .tag(NavigationCoordinator.TabStatus.myPage)
            .tabItem {
                Image(systemName: "person.fill")
                Text("내 정보")
            }
        }
    }
}


private struct AppUpdateDetailDarkModePreviewContainer: View {
    var body: some View {
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
}


private func makePreviewImageData() -> Data {
    let size = CGSize(width: 640, height: 640)
    let renderer = UIGraphicsImageRenderer(size: size)

    return renderer.pngData { context in
        context.cgContext.setFillColor(UIColor.white.cgColor)
        context.cgContext.fill(CGRect(origin: .zero, size: size))

        let configuration = UIImage.SymbolConfiguration(pointSize: 300, weight: .black)
        let symbol = UIImage(systemName: "shoe.fill", withConfiguration: configuration)?
            .withTintColor(.black, renderingMode: .alwaysOriginal)
        symbol?.draw(in: CGRect(x: 110, y: 170, width: 420, height: 300))
    }
}
#endif
