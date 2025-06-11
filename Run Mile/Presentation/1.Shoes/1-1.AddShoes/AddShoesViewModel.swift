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
    
    public var image: Data? {
        willSet {
            if image != newValue {
                isImageBackgroundRemoved = false
            }
        }
    }
    public var name: String = ""
    public var nickname: String = ""
    public var goalMileage: String = ""
    public var runMileage: String = ""
    
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
    
    public var isCompleteButtonAccessible: Bool {
        !name.isEmpty && !nickname.isEmpty && !goalMileage.isEmpty && !(image == nil)
    }
    
    private var previousImage: Data?
    
    init(useCase: AddShoesUseCase) {
        self.useCase = useCase
    }
    
    enum TextFieldCategory: Hashable {
        case name
        case nickname
        case goalMileage
        case runMileage
        
        
        public var placeholder: String {
            switch self {
            case .name:
                return "신발 이름"
            case .nickname:
                return "닉네임"
            case .goalMileage:
                return "목표 마일리지(최대 1000km)"
            case .runMileage:
                return "주행 마일리지(Optional)"
            }
        }
    }
}


extension AddShoesViewModel {
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
            shoesName: self.name,
            nickname: self.nickname,
            goalMileage: Double(self.goalMileage)!,
            currentMileage: self.runMileage.isEmpty ? 0.0 : Double(self.runMileage)!,
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
