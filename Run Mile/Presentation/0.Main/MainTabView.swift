//
//  MainTabView.swift
//  Run Mile
//
//  Created by 문인범 on 4/16/25.
//

import SwiftUI


struct MainTabView: View {
    @StateObject private var navigationCoordinator: NavigationCoordinator = .shared
    @StateObject private var viewModel: MainTabViewModel = .init()
    
    var body: some View {
        TabView(selection: $navigationCoordinator.tabStatus) {
            NavigationStack(path: $navigationCoordinator.shoesPath) {
                navigationCoordinator.build(.shoes)
                    .navigationDestination(
                        for: NavigationCoordinator.Screen.self,
                        destination: {
                            navigationCoordinator.build($0)
                        }
                    )
            }
            .tag(NavigationCoordinator.TabStaus.shoes)
            .tabItem {
                Image(systemName: "shoe.2.fill")
                Text("신발")
            }
            
            NavigationStack(path: $navigationCoordinator.workoutPath) {
                navigationCoordinator.build(.workout)
                    .navigationDestination(
                        for: NavigationCoordinator.Screen.self,
                        destination: {
                            navigationCoordinator.build($0)
                        }
                    )
            }
            .tag(NavigationCoordinator.TabStaus.workout)
            .tabItem {
                Image(systemName: "figure.run")
                Text("운동")
            }
            
            NavigationStack(path: $navigationCoordinator.myPagePath) {
                navigationCoordinator.build(.myPage)
                    .navigationDestination(
                        for: NavigationCoordinator.Screen.self,
                        destination: {
                            navigationCoordinator.build($0)
                        }
                    )
            }
            .tag(NavigationCoordinator.TabStaus.myPage)
            .tabItem {
                Image(systemName: "person.fill")
                Text("내 정보")
            }
        }
        .sheet(item: $navigationCoordinator.sheet) {
            navigationCoordinator.build($0)
        }
//        .navigationDestination()
    }
}


