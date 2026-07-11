//
//  AddShoesViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import Foundation
import SwiftUI
import PhotosUI


@MainActor
@Observable
final class AddShoesViewModel {
    private let useCase: AddShoesUseCase
    
    // MARK: - Properties
    public var image: Data? {
        willSet {
            if image != newValue {
                isImageBackgroundRemoved = false
            }
        }
    }
    
    // Brand & Model Selection
    public var selectedBrand: String = ShoeCatalog.defaultBrand {
        didSet {
            guard oldValue != selectedBrand else { return }
            selectedModel = ShoeCatalog.defaultModel(for: selectedBrand)
        }
    }
    public var selectedModel: String = ShoeCatalog.defaultModel
    public var customBrand: String = ""
    public var customModel: String = ""
    
    // Usage (Previously Nickname)
    public var usage: String = ""
    
    // Mileage
    public var goalMileage: String = ""
    
    // Photo Picker State
    public var photos: PhotosPickerItem? = nil {
        didSet {
            guard let photos else { return }
            let sessionID = beginImageProcessing()
            imageProcessingTask = Task {
                await photoPicked(photos, sessionID: sessionID)
            }
        }
    }
    
    public var isPhotoSheetPresented: Bool = false
    public var isPhotosPickerPresented: Bool = false
    public var isCameraPresented: Bool = false
    public var isImageBackgroundRemoved: Bool = false
    public var isLoading: Bool = false
    
    // Button Accessibility
    public var isCompleteButtonAccessible: Bool {
        return !effectiveShoesName.isEmpty && !usage.isEmpty && !goalMileage.isEmpty && image != nil
    }
    
    private var previousImage: Data?
    private var imageProcessingTask: Task<Void, Never>?
    private var imageProcessingSessionID = UUID()
    
    var brandList: [String] {
        ShoeCatalog.brandList
    }
    
    var modelList: [String] {
        ShoeCatalog.modelList(for: selectedBrand)
    }
    
    // Computed Name
    var effectiveShoesName: String {
        ShoeCatalog.shoesName(
            selectedBrand: selectedBrand,
            selectedModel: selectedModel,
            customBrand: customBrand,
            customModel: customModel
        )
    }
    
    init(useCase: AddShoesUseCase) {
        self.useCase = useCase
    }
}


// MARK: - Actions
extension AddShoesViewModel {
    @MainActor
    public func cancelButtonTapped() {
        cancelImageProcessing()
        NavigationCoordinator.shared.dismissSheet()
    }

    public func viewDidDisappear() {
        cancelImageProcessing()
    }
    
    @MainActor
    public func imageButtonTapped() {
        self.isPhotoSheetPresented.toggle()
    }
    
    @MainActor
    public func photoPickerButtonTapped() {
        self.isPhotosPickerPresented.toggle()
    }
    
    @MainActor
    public func cameraButtonTapped() {
        self.isCameraPresented.toggle()
    }

    @MainActor
    public func cameraImagePicked(_ imageData: Data) {
        let sessionID = beginImageProcessing()

        imageProcessingTask = Task {
            do {
                let normalizedImage = try await useCase.normalizeImage(from: imageData)
                guard isCurrentImageProcessingSession(sessionID) else { return }
                applySelectedImage(normalizedImage)
            } catch {
                guard isCurrentImageProcessingSession(sessionID) else { return }
                NavigationCoordinator.shared.push(.init(
                    title: "사진 처리 과정 중 오류가 발생했습니다.",
                    message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                    firstButton: .cancel(title: "확인", action: {}),
                    secondButton: nil
                ))
            }
            finishImageProcessing(sessionID)
        }
    }
    
    @MainActor
    public func removeBackgroundButtonTapped() {
        if isImageBackgroundRemoved {
            cancelImageProcessing()
            self.image = self.previousImage
            self.previousImage = nil
            isImageBackgroundRemoved = false
            return
        }
        
        guard let image = self.image else {
            return
        }

        let sessionID = beginImageProcessing()
        imageProcessingTask = Task(priority: .background) {
            do {
                let removedImage = try await useCase.removeImageBackground(from: image)
                guard isCurrentImageProcessingSession(sessionID) else { return }
                self.previousImage = image
                self.image = removedImage
                self.isImageBackgroundRemoved = true
            } catch {
                guard isCurrentImageProcessingSession(sessionID) else { return }
                NavigationCoordinator.shared.push(.init(
                    title: "이미지 배경 처리 과정 중 오류가 발생했습니다.",
                    message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                    firstButton: .cancel(title: "확인", action: {}),
                    secondButton: nil
                ))
                
                isImageBackgroundRemoved = false
            }
            finishImageProcessing(sessionID)
        }
    }
    
    @MainActor
    public func saveButtonTapped() {
        guard let image else {
            NavigationCoordinator.shared.push(.init(
                title: "신발 사진을 추가해주세요.",
                message: nil,
                firstButton: .cancel(title: "확인", action: {}),
                secondButton: nil
            ))
            return
        }

        let shoes = Shoes(
            id: .init(),
            image: image,
            shoesName: self.effectiveShoesName,
            nickname: self.usage, // Usage maps to nickname
            goalMileage: Double(self.goalMileage) ?? 0.0,
            currentMileage: 0.0, // Default to 0
            workouts: []
        )
        
        Task {
            await saveShoes(shoes)
        }
    }

    @MainActor
    private func saveShoes(_ shoes: Shoes) async {
        isLoading = true

        do {
            let result = try await useCase.saveShoes(shoes: shoes)
            isLoading = false

            if result.shouldShowNotificationPermissionSheet {
                NavigationCoordinator.shared.presentCustomSheetAfterCurrentSheetDismissal(
                    .addShoesNotificationPermission
                )
            } else {
                NavigationCoordinator.shared.dismissSheet()
            }
        } catch {
            isLoading = false

            NavigationCoordinator.shared.push(.init(
                title: "저장 과정 중 오류가 발생했습니다.",
                message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                firstButton: .cancel(title: "확인", action: {}),
                secondButton: nil
            ))
        }
    }

    private func photoPicked(_ photo: PhotosPickerItem, sessionID: UUID) async {
        do {
            let selectedImage = try await useCase.photoToData(photo: photo)
            guard isCurrentImageProcessingSession(sessionID) else { return }
            applySelectedImage(selectedImage)
        } catch {
            guard isCurrentImageProcessingSession(sessionID) else { return }
            NavigationCoordinator.shared.push(.init(
                title: "사진 선택 과정 중 오류가 발생했습니다.",
                message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                firstButton: .cancel(title: "확인", action: {}),
                secondButton: nil
            ))
        }
        photos = nil
        finishImageProcessing(sessionID)
    }

    private func beginImageProcessing() -> UUID {
        imageProcessingTask?.cancel()
        let sessionID = UUID()
        imageProcessingSessionID = sessionID
        isLoading = true
        return sessionID
    }

    private func finishImageProcessing(_ sessionID: UUID) {
        guard imageProcessingSessionID == sessionID else { return }
        imageProcessingTask = nil
        isLoading = false
    }

    private func cancelImageProcessing() {
        imageProcessingSessionID = UUID()
        imageProcessingTask?.cancel()
        imageProcessingTask = nil
        isLoading = false
    }

    private func isCurrentImageProcessingSession(_ sessionID: UUID) -> Bool {
        !Task.isCancelled && imageProcessingSessionID == sessionID
    }

    private func applySelectedImage(_ imageData: Data) {
        previousImage = nil
        image = imageData
        isImageBackgroundRemoved = false
    }
}
