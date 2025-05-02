//
//  MyPageViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import Foundation


@Observable
final class MyPageViewModel {
    private let useCase: MyPageUseCase
    public var isContactPresented: Bool = false
    
    
    init(useCase: MyPageUseCase) {
        self.useCase = useCase
    }
    
    enum MyPageStatus: CaseIterable {
        case contact
        case fitness
        
        public var cellName: String {
            switch self {
            case .contact:
                "문의하기"
            case .fitness:
                "Fitness 연동하기"
            }
        }
    }
}


extension MyPageViewModel {
    @MainActor
    public func myPageCellTapped(_ status: MyPageStatus) {
        switch status {
        case .contact:
            contactAction()
        case .fitness:
            break
        }
    }
    
    @MainActor
    private func contactAction() {
        if useCase.evaluateMailAvailable() {
            isContactPresented.toggle()
        } else {
            let alertData = AlertData(
                title: "Mail을 사용할 수 없습니다.",
                message: "Mail 앱 설정이 되어있지 않은 경우 사용이 불가합니다.\n다른 연락처로 연락해주세요!",
                firstButton: .cancel(action: {}, title: "확인"),
                secondButton: nil
            )
            
            NavigationCoordinator.shared.push(alertData)
        }
    }
}
