//
//  ShoesDetailViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/19/25.
//

import Foundation


@Observable
final class ShoesDetailViewModel {
    public var shoes: Shoes
    public var viewStatus: ViewStatus = .normal {
        didSet {
            goalMileage = "\(Int(shoes.goalMileage))"
        }
    }
    
    public var goalMileage: String = ""
    
    init(shoes: Shoes) {
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
        self.viewStatus = .normal
    }
}
