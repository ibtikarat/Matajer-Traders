//
//  SceneDelegate.swift
//  Matajer Traders
//
//  Created by Heba lubbad on 9/14/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import UIKit
import Firebase
import MOLH

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window = self.window
        
        initAppInterface()
        
        if MatajerUtility.getNotificationNo() > 0 {
            UIApplication.shared.applicationIconBadgeNumber = MatajerUtility.getNotificationNo()
        }
    }
    func initAppInterface()
    {
        if MOLHLanguage.currentLocaleIdentifier() == "ar" {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        }else {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        
        //UITabBar
        let TabBarItemAppearance =  UITabBarItemAppearance()
        TabBarItemAppearance.selected.iconColor = Constants.PrimaryColor!
        TabBarItemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Constants.PrimaryColor! , NSAttributedString.Key.font: Constants.appFont11Regular]
        TabBarItemAppearance.normal.iconColor = Constants.BlackColor
        TabBarItemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Constants.BlackColor!, NSAttributedString.Key.font:Constants.appFont11Regular]
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = UIColor.white
        tabBarAppearance.backgroundImage = UIImage()
        tabBarAppearance.shadowImage = UIImage()
        tabBarAppearance.shadowColor = Constants.BlackColor
        tabBarAppearance.stackedLayoutAppearance = TabBarItemAppearance
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().shadowImage = UIImage()
        
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateUserInfo"), object: self, userInfo: nil)
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    
}

