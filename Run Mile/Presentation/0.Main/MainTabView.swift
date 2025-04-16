//
//  MainTabView.swift
//  Run Mile
//
//  Created by 문인범 on 4/16/25.
//

import SwiftUI


struct MainTabView: View {
    @StateObject private var viewModel: MainTabViewModel = .init()
    
    var body: some View {
        TabView(selection: $viewModel.tabStatus) {
            ShoesListView()
                .tag(MainTabViewModel.TabStaus.shoes)
                .tabItem {
                    Image(systemName: "shoe.2.fill")
                    Text("신발")
                }
            
            WorkoutListView()
                .tag(MainTabViewModel.TabStaus.runDiary)
                .tabItem {
                    Image(systemName: "figure.run")
                    Text("운동")
                }
            
            MyPageView()
                .tag(MainTabViewModel.TabStaus.myPage)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("내 정보")
                }
        }
    }
}


