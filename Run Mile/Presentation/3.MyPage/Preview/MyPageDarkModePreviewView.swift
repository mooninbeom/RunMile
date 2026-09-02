//
//  MyPageDarkModePreviewView.swift
//  Run Mile
//
//  Created by Codex on 8/30/26.
//

#if DEBUG
import SwiftUI


#Preview("My Page · Light") {
    NavigationStack {
        MyPageView(viewModel: PreviewDIContainer().makeMyPageViewModel())
    }
    .preferredColorScheme(.light)
}


#Preview("My Page · Dark") {
    NavigationStack {
        MyPageView(viewModel: PreviewDIContainer().makeMyPageViewModel())
    }
    .preferredColorScheme(.dark)
}


#Preview("Hall of Fame · Light") {
    NavigationStack {
        HOFView(viewModel: PreviewDIContainer().makeHOFViewModel())
    }
    .preferredColorScheme(.light)
}


#Preview("Hall of Fame · Dark") {
    NavigationStack {
        HOFView(viewModel: PreviewDIContainer().makeHOFViewModel())
    }
    .preferredColorScheme(.dark)
}


#Preview("HOF Report · Light") {
    NavigationStack {
        HOFReportView(
            viewModel: PreviewDIContainer().makeHOFReportViewModel(
                shoes: PreviewShoesMockData.hallOfFameShoes[0]
            )
        )
    }
    .preferredColorScheme(.light)
}


#Preview("HOF Report · Dark") {
    NavigationStack {
        HOFReportView(
            viewModel: PreviewDIContainer().makeHOFReportViewModel(
                shoes: PreviewShoesMockData.hallOfFameShoes[0]
            )
        )
    }
    .preferredColorScheme(.dark)
}


#Preview("Fitness Connect · Light") {
    NavigationStack {
        FitnessConnectView()
            .navigationTitle("운동 데이터 연결")
            .navigationBarTitleDisplayMode(.inline)
    }
    .preferredColorScheme(.light)
}


#Preview("Fitness Connect · Dark") {
    NavigationStack {
        FitnessConnectView()
            .navigationTitle("운동 데이터 연결")
            .navigationBarTitleDisplayMode(.inline)
    }
    .preferredColorScheme(.dark)
}


#Preview("Information · Light") {
    NavigationStack {
        InformationView(viewModel: PreviewDIContainer().makeInformationViewModel())
            .navigationTitle("개발자 정보")
            .navigationBarTitleDisplayMode(.inline)
    }
    .preferredColorScheme(.light)
}


#Preview("Information · Dark") {
    NavigationStack {
        InformationView(viewModel: PreviewDIContainer().makeInformationViewModel())
            .navigationTitle("개발자 정보")
            .navigationBarTitleDisplayMode(.inline)
    }
    .preferredColorScheme(.dark)
}
#endif
