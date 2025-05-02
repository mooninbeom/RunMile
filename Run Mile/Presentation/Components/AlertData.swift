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
        case cancel(action: () -> Void, title: String)
        case ok(action: () -> Void, title: String)
    }
}
