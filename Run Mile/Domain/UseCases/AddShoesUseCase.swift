//
//  AddShoesUseCase.swift
//  Run Mile
//
//  Created by 문인범 on 4/18/25.
//

import Foundation
import SwiftUI
import PhotosUI


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
            throw AddShoesError.transferFailed
        }
    }
    
    public func saveShoes(shoes: Shoes) async throws {
        try await repository.createShoes(shoes: shoes)
    }
}
