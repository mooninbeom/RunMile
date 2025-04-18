//
//  AddShoesUseCase.swift
//  Run Mile
//
//  Created by 문인범 on 4/18/25.
//

import Foundation
import SwiftUICore
import _PhotosUI_SwiftUI


protocol AddShoesUseCase: Sendable {
    func photoToData(photo: PhotosPickerItem) async throws -> Data
}


final class DefaultAddShoesUseCase: AddShoesUseCase {
    public func photoToData(photo: PhotosPickerItem) async throws -> Data {
        if let image = try await photo.loadTransferable(type: Data.self) {
            return image
        } else {
            throw NSError()
        }
    }
}
