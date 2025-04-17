//
//  WorkoutViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import Foundation


final class WorkoutListViewModel: ObservableObject {
    
}



extension WorkoutListViewModel {
    @MainActor
    public func workoutCellTapped() {
        NavigationCoordinator.shared.push(.chooseShoes)
    }
}
