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
    
    public var tabStatus: TabStatus = .shoes
    
    public var shoesPath = NavigationPath()
    public var workoutPath = NavigationPath()
    public var myPagePath = NavigationPath()
    
    public var sheet: Sheet?
    public var isAlertPresented: Bool = false
    public var alert: AlertData?
}


extension NavigationCoordinator {
    @MainActor
    public func push(_ screen: Screen, tab: TabStatus) {
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
    public func switchAndPush(_ screen: Screen, tab: TabStatus) {
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
    public func pop(_ tab: TabStatus) {
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
}


extension NavigationCoordinator {
    enum TabStatus {
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
        case workoutDetail(Workout)
        
        case myPage
        case fitnessConnect
        case hof
        case info
        
        case imageDetail(Data)
    }
    
    enum Sheet {
        var id: Self { self }
        
        case addShoes(() -> Void)
        case chooseShoes([Workout], () -> Void)
        case automaticRegister
    }
}


// MARK: - Protocol
extension NavigationCoordinator.TabStatus: Hashable {}
extension NavigationCoordinator.Screen: Hashable {}
extension NavigationCoordinator.Sheet: Hashable, Identifiable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
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
        switch self {
        case .addShoes:
            hasher.combine("addShoes")
        case let .chooseShoes(workouts, _):
            hasher.combine("chooseShoes")
            hasher.combine(workouts)
        case .automaticRegister:
            hasher.combine("automaticRegister")
        }
    }
}
