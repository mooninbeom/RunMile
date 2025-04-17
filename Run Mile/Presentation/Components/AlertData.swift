//
//  AlertData.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import Foundation


struct AlertData {
    let title: String
    let message: String?
    
    let firstButton: ButtonType?
    let secondButton: ButtonType?
    
    
    enum ButtonType {
        case cancel(action: ()->Void)
        case ok(action: ()->Void)
        
        public var title: String {
            switch self {
            case .cancel:
                "취소"
            case .ok:
                "확인"
            }
        }
    }
}
