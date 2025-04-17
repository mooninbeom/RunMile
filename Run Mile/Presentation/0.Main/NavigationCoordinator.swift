//
//  NavigationCoordinator.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import Foundation
import SwiftUI


final class NavigationCoordinator: ObservableObject {
    static let shared = NavigationCoordinator()
    
    private init() {}
    
    @Published public var tabStatus: TabStaus = .shoes
    
    @Published public var shoesPath = NavigationPath()
    @Published public var workoutPath = NavigationPath()
    @Published public var myPagePath = NavigationPath()
    
    @Published public var sheet: Sheet?
}


extension NavigationCoordinator {
    @MainActor
    public func push(_ screen: Screen, tab: TabStaus) {
        switch tab {
        case .shoes:
            shoesPath.append(screen)
        case .workout:
            workoutPath.append(screen)
        case .myPage:
            myPagePath.append(screen)
        }
    }
    
    @MainActor
    public func push(_ sheet: Sheet) {
        switch sheet {
        case .addShoes:
            self.sheet = sheet
        }
    }
    
    @MainActor
    public func popSheet() {
        self.sheet = nil
    }
    
    @ViewBuilder
    public func build(_ screen: Screen) -> some View {
        switch screen {
        case .shoes:
            ShoesListView()
        case .shoesDetail:
            ShoesDetailView()
        case .workout:
            WorkoutListView()
        case .myPage:
            MyPageView()
        }
    }
    
    @ViewBuilder
    public func build(_ sheet: Sheet) -> some View {
        switch sheet {
        case .addShoes:
            AddShoesView()
        }
    }
}


extension NavigationCoordinator {
    enum TabStaus: Equatable {
        case shoes
        case workout
        case myPage
    }
}


extension NavigationCoordinator {
    enum Screen: Hashable, Equatable {
        case shoes
        case shoesDetail
        
        case workout
        
        case myPage
    }
    
    enum Sheet: Hashable, Equatable, Identifiable {
        var id: Self { self }
        
        case addShoes
    }
}
