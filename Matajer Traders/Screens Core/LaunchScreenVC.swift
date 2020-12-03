//
//  LaunchScreenVC.swift
//  tamween
//
//  Created by Heba lubbad on 6/25/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import UIKit
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

class LaunchScreenVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mainStoryboard = UIStoryboard(name: "Registration", bundle: nil)
        if MatajerUtility.isFirstTime(){
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            let root_vc = (mainStoryboard.instantiateViewController(withIdentifier: "IntroductionScreensVC") as? IntroductionScreensVC)!
            let frontNavigationController = UINavigationController(rootViewController: root_vc)
            frontNavigationController.navigationBar.isHidden = true
            UIApplication.shared.windows.first?.rootViewController = frontNavigationController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
            
        }else if  !MatajerUtility.isLogin() {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            let root_vc = (mainStoryboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC)!
            let frontNavigationController = UINavigationController(rootViewController: root_vc)
            frontNavigationController.navigationBar.isHidden = true
            UIApplication.shared.windows.first?.rootViewController = frontNavigationController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
        }else {
            startReqestGetUserData()
        }
        
        
    }
    
    
    func startReqestGetUserData()
    {
        API.GET_USER.startRequest(showIndicator: false) { (api, response) in
            if response.isSuccess {
                let value = response.data as! [String :Any]
                let userData = try! JSONSerialization.data(withJSONObject: value, options: [])
                let user = try! JSONDecoder().decode(User.self, from: userData)
                if user.storeData?.ios_popup_topic?.count ?? 0 > 0 {
                    #if DEBUG
                    Messaging.messaging().subscribe(toTopic: "test\(user.storeData?.ios_popup_topic! ?? "IosMatajerAppTopic-3")") { error in
                                                 if error == nil {
                                                     
                                                     print("Subscribed to ios Topic Package")
                                                 }
                                             }
                            
                    #else
                    Messaging.messaging().subscribe(toTopic: (user.storeData?.ios_popup_topic!)!) { error in
                                                 if error == nil {
                                                     
                                                     print("Subscribed to ios Topic Package")
                                                 }
                                             }
                            
                    #endif
}
                MatajerUtility.saveUser(user: user)
                
                UIApplication.shared.applicationIconBadgeNumber = user.notificationAlarm ?? 0
                MatajerUtility.setNotificationNo(notifcation_number:user.notificationAlarm ?? 0)
                  DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.routeToHome()
               }
            }
        }
    }
    
}
