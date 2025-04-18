//
//  AddShoesViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import Foundation
import _PhotosUI_SwiftUI


@Observable
final class AddShoesViewModel {
    private let useCase: AddShoesUseCase
    
    public var image: Data?
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
    
    init(useCase: AddShoesUseCase) {
        self.useCase = useCase
    }
    
    enum TextFieldCategory {
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
    
    public func photoPicked() async {
        if let photo = self.photos {
            do {
                let result = try await useCase.photoToData(photo: photo)
                self.image = result
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
