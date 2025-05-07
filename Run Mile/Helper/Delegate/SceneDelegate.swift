//
//  SceneDelegate.swift
//  Run Mile
//
//  Created by 문인범 on 5/7/25.
//

import UIKit
import SwiftUI


final class SceneDelegate: NSObject, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        window?.rootViewController = UIHostingController(rootView: MainTabView().tint(.primary1))
        window?.makeKeyAndVisible()
    }
    
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        print(#function)
//        UserDefaults.standard.isFirstLaunch = true
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        print(#function)
//        UserDefaults.standard.isFirstLaunch = false
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        print(#function)
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        print(#function)
//        UserDefaults.standard.isFirstLaunch = false
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        print(#function)
    }
}
