//
//  ShoesListViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import Foundation


final class ShoesListViewModel: ObservableObject {
    @Published public var isAddShoesSheetPresented: Bool = false
}


extension ShoesListViewModel {
    public func addShoesButtonTapped() {
        self.isAddShoesSheetPresented.toggle()
    }
}
