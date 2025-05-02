//
//  MyPageViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import Foundation


@Observable
final class MyPageViewModel {
    public var isContactPresented: Bool = false
    
    
    
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
            isContactPresented.toggle()
        case .fitness:
            break
        }
    }
}
