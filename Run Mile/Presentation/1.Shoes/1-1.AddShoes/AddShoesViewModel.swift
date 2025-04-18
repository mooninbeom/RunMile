//
//  AddShoesViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import Foundation


@Observable
final class AddShoesViewModel {
    public var name: String = ""
    public var nickname: String = ""
    public var goalMileage: String = ""
    public var runMileage: String = ""
    
    public var isPhotoSheetPresented: Bool = false
    
    enum TextFieldCategory {
        case name
        case nickname
        case goalMileage
        case runMileage
        
        
        public var placeholder: String {
            switch self {
            case .name:
                return "신발 이름"
            case .nickname:
                return "닉네임"
            case .goalMileage:
                return "목표 마일리지(최대 1000km)"
            case .runMileage:
                return "주행 마일리지(Optional)"
            }
        }
    }
}


extension AddShoesViewModel {
    @MainActor
    public func cancelButtonTapped() {
        NavigationCoordinator.shared.dismissSheet()
    }
}
