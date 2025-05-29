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
    public func deleteButtonTapped() {
        let alert = AlertData(
            title: "정말 삭제하시겠습니까?",
            message: "삭제된 데이터는 되돌릴 수 없습니다.",
            firstButton: .cancel(title: "취소") {},
            secondButton: .ok(title: "삭제") {
                self.deleteShoes()
            }
        )
        
        NavigationCoordinator.shared.push(alert)
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


// MARK: - Internal Function
extension ShoesDetailViewModel {
    private func deleteShoes() {
        Task {
            do {
                try await useCase.deleteShoes(shoes: self.shoes)
                let alert = AlertData(
                    title: "삭제를 완료했습니다.",
                    message: nil,
                    firstButton: .cancel(title: "확인") {
                        Task {
                            await NavigationCoordinator.shared.pop(.shoes)
                        }
                    },
                    secondButton: nil
                )
                
                await NavigationCoordinator.shared.push(alert)
                
            } catch {
                let alert = AlertData(
                    title: "삭제에 실패했습니다!",
                    message: error.localizedDescription,
                    firstButton: .cancel(title: "확인", action: {}),
                    secondButton: nil
                )
                
                await NavigationCoordinator.shared.push(alert)
            }
        }
    }
}
