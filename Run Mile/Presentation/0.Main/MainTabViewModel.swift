//
//  MainTabViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/16/25.
//

import Foundation


final class MainTabViewModel: ObservableObject {
    public var tabStatus: TabStaus = .shoes
    
    
    
    
    
    enum TabStaus: Equatable {
        case shoes
        case runDiary
        case myPage
    }
}
