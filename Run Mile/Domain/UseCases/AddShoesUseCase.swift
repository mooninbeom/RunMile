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
    func saveShoes(shoes: Shoes) async throws
}


final class DefaultAddShoesUseCase: AddShoesUseCase {
    private let repository: ShoesDataRepository
    
    init(repository: ShoesDataRepository) {
        self.repository = repository
    }
    
    
    public func photoToData(photo: PhotosPickerItem) async throws -> Data {
        if let image = try await photo.loadTransferable(type: Data.self) {
            return image
        } else {
            // TODO: 에러 처리
            throw NSError()
        }
    }
    
    public func saveShoes(shoes: Shoes) async throws {
        try await repository.createShoes(shoes: shoes)
    }
}
