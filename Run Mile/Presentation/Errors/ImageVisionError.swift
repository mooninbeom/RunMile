//
//  ImageVisionError.swift
//  Run Mile
//
//  Created by 문인범 on 6/10/25.
//

import Foundation


/**
 Vision(이미지 배경 추출) 관련 에러
 */
enum ImageVisionError: Error {
    case preprocessingFailed
    case noSubjectFound
    case createciImageFailed
    case createPNGDataFailed
}


extension ImageVisionError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .preprocessingFailed:
            NSLocalizedString("이미지 전처리 과정에서 오류 발생", comment: "Preprocessing Failed")
        case .noSubjectFound:
            NSLocalizedString("추출된 이미지가 없음", comment: "No Subject Found")
        case .createciImageFailed:
            NSLocalizedString("CIImage 생성 실패", comment: "Create CIimage Failed")
        case .createPNGDataFailed:
            NSLocalizedString("PNG데이터 생성 실패", comment: "Create PNG Data Failed")
        }
    }
}
