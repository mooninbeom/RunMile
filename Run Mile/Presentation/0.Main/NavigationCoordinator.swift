//
//  NavigationCoordinator.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import Foundation
import SwiftUI


@Observable
final class NavigationCoordinator {
    static let shared = NavigationCoordinator()
    
    private init() {}
    
    public var tabStatus: TabStaus = .shoes
    
    public var shoesPath = NavigationPath()
    public var workoutPath = NavigationPath()
    public var myPagePath = NavigationPath()
    
    public var sheet: Sheet?
    public var isAlertPresented: Bool = false
    public var alert: AlertData?
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
        self.sheet = sheet
    }
    
    @MainActor
    public func push(_ alert: AlertData) {
        self.alert = alert
        isAlertPresented.toggle()
    }
    
    @MainActor
    public func dismissSheet() {
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
        case .chooseShoes:
            ChooseShoesView()
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
        case chooseShoes
    }
}
