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
    public func pop(_ tab: TabStaus) {
        switch tab {
        case .shoes:
            shoesPath.removeLast()
        case .workout:
            workoutPath.removeLast()
        case .myPage:
            myPagePath.removeLast()
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
        case let .hofShoesDetail(shoes):
            HOFShoesDetailView(shoes: shoes)
        case .info:
            InformationView()
        case let .imageDetail(image):
            if #available(iOS 18.0, *) {
                ImageDetailView(image: image)
                    .toolbarVisibility(.hidden, for: .tabBar)
            } else {
                ImageDetailView(image: image)
                    .toolbar(.hidden, for: .tabBar)
            }
        }
    }
    
    @ViewBuilder
    public func build(_ sheet: Sheet) -> some View {
        switch sheet {
        case let .addShoes(action):
            AddShoesView(dismissAction: action)
        case let .chooseShoes(workouts, action):
            ChooseShoesView(workouts: workouts, dismiss: action)
        case .automaticRegister:
            AutoMileageShoesView()
        }
    }
}


extension NavigationCoordinator {
    enum TabStaus {
        case shoes
        case workout
        case myPage
    }
}


extension NavigationCoordinator {
    enum Screen {
        case shoes
        case shoesDetail(Shoes)
        
        case workout
        
        case myPage
        case fitnessConnect
        case hof
        case hofShoesDetail(Shoes)
        case info
        
        case imageDetail(Data)
    }
    
    enum Sheet {
        var id: Self { self }
        
        case addShoes(() -> Void)
        case chooseShoes([RunningData], () -> Void)
        case automaticRegister
    }
}


// MARK: - Protocol
extension NavigationCoordinator.TabStaus: Hashable {}
extension NavigationCoordinator.Screen: Hashable {}
extension NavigationCoordinator.Sheet: Hashable, Identifiable {
    static func == (rhs: Self, lhs: Self) -> Bool {
        switch (rhs, lhs) {
        case (.addShoes, .addShoes):
            return true
        case let (.chooseShoes(first, _), .chooseShoes(second, _)):
            return first == second
        case (.automaticRegister, .automaticRegister):
            return true
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}
