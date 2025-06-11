//
//  InformationViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 5/3/25.
//

import UIKit
import SwiftUI


final class InformationViewModel {
    
}

extension InformationViewModel {
    @MainActor
    public func onMemojiAppear() -> Image {
        let url = Bundle.main.url(forResource: "memoji", withExtension: "heic")!
        let data = try! Data(contentsOf: url)
        return data.toImage()!
    }
    
    @MainActor
    public func onGithubAppear() -> Image {
        let url = Bundle.main.url(forResource: "github", withExtension: "png")!
        let data = try! Data(contentsOf: url)
        return data.toImage()!
    }
    
    @MainActor
    public func onLinkedInAppear() -> Image {
        let url = Bundle.main.url(forResource: "linkedIn", withExtension: "png")!
        let data = try! Data(contentsOf: url)
        return data.toImage()!
    }
    
    @MainActor
    public func mailButtonTapped() {
        UIPasteboard.general.string = "dlsqja567@naver.com"
        NavigationCoordinator.shared.push(.init(
            title: "복사가 완료되었습니다!",
            message: nil,
            firstButton: .cancel(title: "확인", action: {}),
            secondButton: nil
        ))
    }
}
