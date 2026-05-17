//
//  HOFViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 5/31/25.
//

import Foundation


@Observable
final class HOFViewModel {
    public var shoes: [Shoes] = [] {
        didSet {
            shoeCards = shoes.map(HOFShoesCardInfo.init)
        }
    }
    public private(set) var shoeCards: [HOFShoesCardInfo] = []
    
    
    private let useCase: HOFUseCase
    
    init(useCase: HOFUseCase) {
        self.useCase = useCase
    }
}


extension HOFViewModel {
    /// 명예의 전당에 진입할 때 졸업 신발 목록을 불러와 카드 표시 모델로 변환합니다.
    @MainActor
    public func onAppear() async {
        do {
            self.shoes = try await self.useCase.fetchShoes()
        } catch {
            NavigationCoordinator.shared.push(.init(
                title: "데이터 로딩 과정 중 오류가 발생했습니다.",
                message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                firstButton: .cancel(title: "확인", action: {}),
                secondButton: nil
            ))
        }
    }
    
    /// 선택한 졸업 신발의 리포트 화면으로 이동합니다.
    @MainActor
    public func shoesCellTapped(card: HOFShoesCardInfo) {
        NavigationCoordinator.shared.push(.hofReport(card.shoes), tab: .myPage)
    }
}


struct HOFShoesCardInfo: Identifiable {
    let id: UUID
    let shoes: Shoes
    let imageData: Data
    let nickname: String
    let shoesName: String
    let totalMileageText: String
    let achievementRateText: String
    
    init(shoes: Shoes) {
        self.id = shoes.id
        self.shoes = shoes
        self.imageData = shoes.image
        self.nickname = shoes.nickname
        self.shoesName = shoes.shoesName
        self.totalMileageText = "\(Int(shoes.totalMileage))"
        
        let achievementRate: Int
        if shoes.goalMileage > 0 {
            achievementRate = Int((shoes.totalMileage / shoes.goalMileage * 100).rounded())
        } else {
            achievementRate = 0
        }
        self.achievementRateText = "목표 \(achievementRate)%"
    }
}
