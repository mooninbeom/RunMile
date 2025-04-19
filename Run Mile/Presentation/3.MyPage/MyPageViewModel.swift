//
//  MyPageViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import Foundation


@Observable
final class MyPageViewModel {
    
    
    
    
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
