//
//  ChooseShoesUseCase.swift
//  Run Mile
//
//  Created by 문인범 on 5/2/25.
//

import Foundation


protocol ChooseShoesUseCase: Sendable {
    func fetchShoesList() async throws -> [Shoes]
    func registerWorkouts(shoes: Shoes, workouts: [Workout]) async throws
}



final class DefaultChooseShoesUseCase: ChooseShoesUseCase {
    private let repository: ShoesDataRepository
    
    init(repository: ShoesDataRepository) {
        self.repository = repository
    }
    
    public func fetchShoesList() async throws -> [Shoes] {
        try await repository.fetchCurrentShoes()
    }
    
    public func registerWorkouts(shoes: Shoes, workouts: [Workout]) async throws {
        var newWorkouts = shoes.workouts
        
        if newWorkouts.contains(workouts) {
            if workouts.count == 1 {
                await NavigationCoordinator.shared.push(
                    .init(
                        title: "중복된 운동 데이터입니다.",
                        message: "다시 시도해주세요!",
                        firstButton: .cancel(title: "확인", action: {}),
                        secondButton: nil
                    )
                )
            } else {
                workouts.forEach {
                    if !newWorkouts.contains($0) {
                        newWorkouts.append($0)
                    }
                }
                
                let newShoes = Shoes(
                    id: shoes.id,
                    image: shoes.image,
                    shoesName: shoes.shoesName,
                    nickname: shoes.nickname,
                    goalMileage: shoes.goalMileage,
                    currentMileage: shoes.currentMileage,
                    workouts: newWorkouts
                )
                
                try await repository.updateShoes(shoes: newShoes)
                
                await NavigationCoordinator.shared.push(
                    .init(
                        title: "중복된 운동 데이터가 포함되어 있습니다.",
                        message: "해당 데이터를 제외한 나머지 운동 데이터만 저장 완료 했습니다.",
                        firstButton: .cancel(title: "확인", action: {}),
                        secondButton: nil
                    )
                )
            }
        } else {
            newWorkouts.append(contentsOf: workouts)
            
            let newShoes = Shoes(
                id: shoes.id,
                image: shoes.image,
                shoesName: shoes.shoesName,
                nickname: shoes.nickname,
                goalMileage: shoes.goalMileage,
                currentMileage: shoes.currentMileage,
                workouts: newWorkouts
            )
            
            try await repository.updateShoes(shoes: newShoes)
        }
    }
    
    
}
