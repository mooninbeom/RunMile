//
//  AddShoesUseCase.swift
//  Run Mile
//
//  Created by 문인범 on 4/18/25.
//

import Foundation
import SwiftUI
import PhotosUI


struct AddShoesSaveResult: Sendable {
    let shouldShowNotificationPermissionSheet: Bool
}


protocol AddShoesUseCase: Sendable {
    func photoToData(photo: PhotosPickerItem) async throws -> Data
    func normalizeImage(from imageData: Data) async throws -> Data
    func removeImageBackground(from imageData: Data) async throws -> Data
    func saveShoes(shoes: Shoes) async throws -> AddShoesSaveResult
}


final class DefaultAddShoesUseCase: AddShoesUseCase {
    private let repository: ShoesDataRepository
    private let notificationPermissionService: NotificationPermissionService
    private let imageProcessingService: ShoeImageProcessingService
    
    init(
        repository: ShoesDataRepository,
        notificationPermissionService: NotificationPermissionService,
        imageProcessingService: ShoeImageProcessingService
    ) {
        self.repository = repository
        self.notificationPermissionService = notificationPermissionService
        self.imageProcessingService = imageProcessingService
    }
    
    
    public func photoToData(photo: PhotosPickerItem) async throws -> Data {
        if let image = try await photo.loadTransferable(type: Data.self) {
            return try await normalizeImage(from: image)
        } else {
            throw AddShoesError.transferFailed
        }
    }

    public func normalizeImage(from imageData: Data) async throws -> Data {
        try await imageProcessingService.normalizeImage(from: imageData)
    }

    public func removeImageBackground(from imageData: Data) async throws -> Data {
        try await imageProcessingService.removeBackground(from: imageData)
    }
    
    public func saveShoes(shoes: Shoes) async throws -> AddShoesSaveResult {
        let savedShoes = try await repository.fetchAllShoes()
        let isFirstShoes = savedShoes.isEmpty

        try await repository.createShoes(shoes: shoes)

        let notificationStatus = await notificationPermissionService.authorizationStatus()
        return AddShoesSaveResult(
            shouldShowNotificationPermissionSheet: isFirstShoes && notificationStatus == .notDetermined
        )
    }
}
