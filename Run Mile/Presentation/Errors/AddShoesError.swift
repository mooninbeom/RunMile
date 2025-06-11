//
//  AddShoesError.swift
//  Run Mile
//
//  Created by 문인범 on 6/10/25.
//

import Foundation


/**
 신발 추가 액션 관련 Error
 */
enum AddShoesError: Error {
    case transferFailed
}


extension AddShoesError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .transferFailed:
            NSLocalizedString("이미지에서 데이터로 변환 실패", comment: "Transfer image to data failed")
        }
    }
}
