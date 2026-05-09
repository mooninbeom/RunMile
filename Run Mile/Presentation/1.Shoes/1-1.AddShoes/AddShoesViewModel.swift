//
//  AddShoesViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import Foundation
import SwiftUI
import PhotosUI
import UserNotifications


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
            Task {
                await photoPicked()
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


// MARK: - TextField Categories
extension AddShoesViewModel {
    enum TextFieldCategory: Hashable {
        case customBrand
        case customModel
        case usage
        case goalMileage
        
        // Helper to determine next/previous based on current state
        func previous(viewModel: AddShoesViewModel) -> TextFieldCategory? {
            switch self {
            case .customBrand:
                return nil
            case .customModel:
                return viewModel.selectedBrand == ShoeCatalog.other ? .customBrand : nil
            case .usage:
                if viewModel.selectedBrand == ShoeCatalog.other || viewModel.selectedModel == ShoeCatalog.other {
                    return .customModel
                }
                return nil
            case .goalMileage:
                return .usage
            }
        }
        
        func next(viewModel: AddShoesViewModel) -> TextFieldCategory? {
            switch self {
            case .customBrand:
                return .customModel
            case .customModel:
                return .usage
            case .usage:
                return .goalMileage
            case .goalMileage:
                return nil
            }
        }
    }
}


// MARK: - Actions
extension AddShoesViewModel {
    @MainActor
    public func keyboardToolbarUpButtonTapped(_ textField: inout TextFieldCategory?) {
        guard let current = textField else { return }
        if let previous = current.previous(viewModel: self) {
            textField = previous
        }
    }
    
    @MainActor
    public func keyboardToolbarDownButtonTapped(_ textField: inout TextFieldCategory?) {
        guard let current = textField else { return }
        if let next = current.next(viewModel: self) {
            textField = next
        }
    }
    
    @MainActor
    public func keyboardToolbarCompleteButtonTapped(_ textField: inout TextFieldCategory?) {
        textField = nil
    }
    
    @MainActor
    public func cancelButtonTapped() {

        NavigationCoordinator.shared.dismissSheet()
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
    public func removeBackgroundButtonTapped() {
        self.isLoading = true
        
        if isImageBackgroundRemoved {
            self.image = self.previousImage
            self.previousImage = nil
            isImageBackgroundRemoved = false
            self.isLoading = false
            return
        }
        
        guard let image = self.image else {
            self.isLoading = false
            return
        }
        
        Task(priority: .background) {
            do {
                let removedImage = try await ImageVisionManager.removeImageBackground(from: image)
                self.previousImage = self.image
                self.image = removedImage
                self.isImageBackgroundRemoved = true
            } catch {
                NavigationCoordinator.shared.push(.init(
                    title: "이미지 배경 처리 과정 중 오류가 발생했습니다.",
                    message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                    firstButton: .cancel(title: "확인", action: {}),
                    secondButton: nil
                ))
                
                isImageBackgroundRemoved = false
            }
            self.isLoading = false
        }
    }
    
    public func saveButtonTapped() {
        let shoes = Shoes(
            id: .init(),
            image: self.image!,
            shoesName: self.effectiveShoesName,
            nickname: self.usage, // Usage maps to nickname
            goalMileage: Double(self.goalMileage) ?? 0.0,
            currentMileage: 0.0, // Default to 0
            workouts: []
        )
        
        Task {
            do {
                try await useCase.saveShoes(shoes: shoes)
            } catch {
                await NavigationCoordinator.shared.push(.init(
                    title: "저장 과정 중 오류가 발생했습니다.",
                    message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                    firstButton: .cancel(title: "확인", action: {}),
                    secondButton: nil
                ))
            }
            
            await NavigationCoordinator.shared.dismissSheet()
        }
    }
    
    public func photoPicked() async {
        if let photo = self.photos {
            do {
                let result = try await useCase.photoToData(photo: photo)
                self.image = result
            } catch {
                await NavigationCoordinator.shared.push(.init(
                    title: "사진 선택 과정 중 오류가 발생했습니다.",
                    message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                    firstButton: .cancel(title: "확인", action: {}),
                    secondButton: nil
                ))
            }
        }
    }
}
