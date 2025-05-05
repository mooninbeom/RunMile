//
//  InformationViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 5/3/25.
//

import UIKit
import SwiftUICore


final class InformationViewModel {
    
}

extension InformationViewModel {
    @MainActor
    public func onMemojiAppear() -> UIImage {
        let url = Bundle.main.url(forResource: "memoji", withExtension: "heic")!
        let data = try! Data(contentsOf: url)
        return UIImage(data: data)!
    }
    
    @MainActor
    public func onGithubAppear() -> UIImage {
        let url = Bundle.main.url(forResource: "github", withExtension: "png")!
        let data = try! Data(contentsOf: url)
        return UIImage(data: data)!
    }
    
    @MainActor
    public func onLinkedInAppear() -> UIImage {
        let url = Bundle.main.url(forResource: "linkedIn", withExtension: "png")!
        let data = try! Data(contentsOf: url)
        return UIImage(data: data)!
    }
    
    @MainActor
    public func mailButtonTapped() {
        UIPasteboard.general.string = "dlsqja567@naver.com"
        NavigationCoordinator.shared.push(.init(
            title: "복사가 완료되었습니다!",
            message: nil,
            firstButton: .cancel(action: {}, title: "확인"),
            secondButton: nil
        ))
    }
}
