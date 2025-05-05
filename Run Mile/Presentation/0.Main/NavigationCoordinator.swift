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
    public func switchAndPush(_ screen: Screen, tab: TabStaus) {
        tabStatus = tab
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
    public func dismissSheet() {
        self.sheet = nil
    }
    
    @ViewBuilder
    public func build(_ screen: Screen) -> some View {
        switch screen {
        case .shoes:
            ShoesListView()
        case let .shoesDetail(shoes):
            ShoesDetailView(shoes: shoes)
            
        case .workout:
            WorkoutListView()
            
        case .myPage:
            MyPageView()
        case .fitnessConnect:
            FitnessConnectView()
        case .hof:
            HOFView()
        case .info:
            InformationView()
        }
    }
    
    @ViewBuilder
    public func build(_ sheet: Sheet) -> some View {
        switch sheet {
        case .addShoes:
            AddShoesView()
        case let .chooseShoes(workout):
            ChooseShoesView(workout: workout)
        }
    }
}


extension NavigationCoordinator {
    enum TabStaus: Hashable {
        case shoes
        case workout
        case myPage
    }
}


extension NavigationCoordinator {
    enum Screen: Hashable {
        case shoes
        case shoesDetail(Shoes)
        
        case workout
        
        case myPage
        case fitnessConnect
        case hof
        case info
    }
    
    enum Sheet: Hashable, Identifiable {
        var id: Self { self }
        
        case addShoes
        case chooseShoes(RunningData)
    }
}
