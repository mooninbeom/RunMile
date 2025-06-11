//
//  MyPageUseCase.swift
//  Run Mile
//
//  Created by 문인범 on 5/2/25.
//

import Foundation
import MessageUI


protocol MyPageUseCase {
    func evaluateMailAvailable() -> Bool
}


final class DefaultMyPageUseCase: MyPageUseCase {
    func evaluateMailAvailable() -> Bool {
        MFMailComposeViewController.canSendMail()
    }
}
