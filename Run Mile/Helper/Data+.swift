//
//  Data+.swift
//  Run Mile
//
//  Created by 문인범 on 5/28/25.
//

import Foundation
import SwiftUI


extension Data {
    /// Data에서 SwiftUI Image 타입으로 변환하는 메소드
    public func toImage() -> Image? {
        guard let uiImage = UIImage(data: self) else {
            return nil
        }
        
        return Image(uiImage: uiImage)
    }
}
