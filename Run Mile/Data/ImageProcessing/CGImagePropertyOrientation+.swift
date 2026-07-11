//
//  CGImagePropertyOrientation+.swift
//  Run Mile
//
//  Created by 문인범 on 5/28/25.
//

import UIKit
import ImageIO


extension CGImagePropertyOrientation {
    /// UIImage의 Orientation -> CGImage의 Orientation 변환
    init(uiImageOrientation: UIImage.Orientation) {
        switch uiImageOrientation {
        case .up:
            self = .up
        case .down:
            self = .down
        case .left:
            self = .left
        case .right:
            self = .right
        case .upMirrored:
            self = .upMirrored
        case .downMirrored:
            self = .downMirrored
        case .leftMirrored:
            self = .leftMirrored
        case .rightMirrored:
            self = .rightMirrored
        @unknown default:
            self = .up
        }
    }
}
