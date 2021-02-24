//
//  AppDelegate.swift
//  Matajer Traders
//
//  Created by Heba lubbad on 9/14/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import UIKit
import CoreData
import MOLH
import IQKeyboardManagerSwift
import Firebase
import Sentry


@UIApplicationMain
class AppDelegate:  UIResponder, UIApplicationDelegate , UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        registerNotification()
        IQKeyboardManager.shared.enable = true
        initLanguage()
        MOLH.setLanguageTo("ar")
        SentrySDK.start { options in
              options.dsn = "https://4869c09cf6a64f0f9002fafdfea11dd3@o461548.ingest.sentry.io/5463474"
              options.debug = true // Enabled debug when first installing is always helpful
          }
        return true
    }
    
    func registerNotification(){
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        
        let center  = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
            if error == nil{
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        Messaging.messaging().delegate = self
        
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        
        print("will present user info\(notification.request.content.userInfo)")
        let userInfo = notification.request.content.userInfo
        if userInfo["badge"] != nil {
            let badge = userInfo["badge"] as? String ?? "0"
            
            let badge_no = Int(badge)
            if badge_no  ?? 0 > 0 {
                MatajerUtility.setNotificationNo(notifcation_number:badge_no ?? 0 )
                UIApplication.shared.applicationIconBadgeNumber = badge_no ?? 0
                let BadgeInfo = ["badge": badge_no ?? 0] as [String : Any]
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateNotificationNumber"), object: self, userInfo: BadgeInfo)
            }
            
        }
        if userInfo["model"] as? String ?? "" == "info" || userInfo["model_name"] as? String ?? "" == "info" {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateUserInfo"), object: self, userInfo: nil)
        }
        
        
        completionHandler([.alert, .badge, .sound])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(" did rcv user info\(response.notification.request.content.userInfo)")
        let userInfo = response.notification.request.content.userInfo
        if userInfo["model_name"] as? String ?? "" == "orders" {
            var orderNo:String = ""
            let id = userInfo["id"] as? String ?? "0"
            let order_id = Int(id)
            if userInfo["order_number"] != nil {
                orderNo =  userInfo["order_number"] as? String ?? ""
            }
            let Info = ["id":order_id ?? 0,"order_number": orderNo] as [String : Any]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GoToOrders"), object: self, userInfo: Info)
        }
        
        if userInfo["badge"] != nil {
            let badge = userInfo["badge"] as? String ?? "0"
            
            let badge_no = Int(badge)
            if badge_no  ?? 0 > 0 {
                MatajerUtility.setNotificationNo(notifcation_number:badge_no ?? 0 )
                UIApplication.shared.applicationIconBadgeNumber = badge_no ?? 0
                let BadgeInfo = ["badge": badge_no ?? 0] as [String : Any]
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateNotificationNumber"), object: self, userInfo: BadgeInfo)
            }
            
        }
        
        if userInfo["model_name"] as? String ?? "" == "info" {
            let iosPopupTopic = userInfo["ios_popup_topic"] as? String ?? ""
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GoToNotifications"), object: self, userInfo: nil)
            if MatajerUtility.isLogin() {
                
                Messaging.messaging().subscribe(toTopic: iosPopupTopic) { error in
                    if error == nil {
                        
                        print("Subscribed to ios Topic Package")
                    }
                }
            }
        }
        if userInfo["model_name"] as? String ?? "" == "popup" {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GoToSuperNotifications"), object: self, userInfo: nil)
        }
        
        completionHandler()
    }
    
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Matajer_Traders")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
extension AppDelegate : MOLHResetable{
    static var shared : AppDelegate{
        get{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            return appDelegate
        }
    }
    
    
    func initLanguage(){
        MOLHLanguage.setDefaultLanguage("ar")
        
        MOLH.shared.activate(true)
    }
    
    
    var viewController :UIViewController {
        get{
            var topController = self.window!.rootViewController!
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            return topController
        }
    }
    
    var language :String {
        set{
            MOLH.setLanguageTo(newValue)
            MOLH.reset()
        }
        get{
            return MOLHLanguage.currentLocaleIdentifier()
        }
    }
    
    
    
    func reset() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LaunchScreenVC")
        self.window!.rootViewController = vc
    }
    
}

extension AppDelegate: MessagingDelegate {
    
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "")")
        
        MatajerUtility.saveFcmToken(fcmToken: fcmToken ?? "")
        if  MatajerUtility.isLogin()
        {
            Messaging.messaging().subscribe(toTopic: API.FIREBASE_SUBSCRIBE_iosArTopic)
            Messaging.messaging().subscribe(toTopic: API.FIREBASE_SUBSCRIBE_iosTopic) { error in
                if error == nil {
                    
                    print("Subscribed to ios Topic topic")
                }
            }
            
            
        }
        
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }
    }
}

