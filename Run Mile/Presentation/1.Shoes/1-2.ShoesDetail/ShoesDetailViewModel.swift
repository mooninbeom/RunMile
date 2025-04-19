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
    
    init(shoes: Shoes) {
        self.shoes = shoes
    }
}
