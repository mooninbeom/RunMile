//
//  ShoesDetailViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/19/25.
//

import Foundation


@Observable
final class ShoesDetailViewModel {
    private let useCase: ShoesDetailUseCase
    
    public var shoes: Shoes
    public var viewStatus: ViewStatus = .normal {
        didSet {
            goalMileage = "\(Int(shoes.goalMileage))"
        }
    }
    
    public var goalMileage: String = ""
    
    init(useCase: ShoesDetailUseCase, shoes: Shoes) {
        self.useCase = useCase
        self.shoes = shoes
    }
    
    enum ViewStatus: Equatable {
        case normal
        case editing
    }
}


extension ShoesDetailViewModel {
    @MainActor
    public func editButtonTapped() {
        self.viewStatus = .editing
    }
    
    @MainActor
    public func cancelButtonTapped() {
        self.viewStatus = .normal
    }
    
    @MainActor
    public func completeButtonTapped() {
        let modified = Shoes(
            id: shoes.id,
            image: shoes.image,
            shoesName: shoes.shoesName,
            nickname: shoes.nickname,
            goalMileage: Double(goalMileage)!,
            currentMileage: shoes.currentMileage,
            workouts: shoes.workouts
        )
        
        Task {
            do {
                try await useCase.editShoes(shoes: modified)
                self.shoes = modified
                self.viewStatus = .normal
            } catch {
                // TODO: 에러 처리
                print(#function)
            }
        }
    }
}
