//
//  TamweenUtility.swift
//  tamween
//
//  Created by Heba lubbad on 7/13/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import UIKit
import FirebaseMessaging
import FirebaseInstanceID


class MatajerUtility: NSObject {
    
    
    
    static func isLogin() -> Bool{
        return UserDefaults.standard.object(forKey: "user") != nil
    }
    
    static func GreaterIphoneX() -> Bool {
        let screenWidht = UIScreen.main.bounds.size.width
        
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone) {
            
            if ( screenWidht > 375) {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    
    static func saveFcmToken(fcmToken :String){
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
    }
    static func getFcmToken() -> String{
        return UserDefaults.standard.value(forKey: "fcmToken") as? String ?? ""
        
    }
    
  
    static func saveUser(user :User){
        UserDefaults.standard.set(try! PropertyListEncoder().encode(user), forKey: "user")
    }
    
    
    static func loadUser() -> User?{
        let storedObject: Data? = UserDefaults.standard.object(forKey: "user") as? Data
        if(storedObject != nil){
            guard let user :User =  try? PropertyListDecoder().decode(User.self, from: storedObject!) else {
                return nil
            }
            return user
        }
        return nil
        
    }
    
    static func isFirstTime() -> Bool{
         let hasBeenLaunchedBeforeFlag = "hasBeenLaunchedBeforeFlag"
            let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunchedBeforeFlag)
            if (isFirstLaunch) {
                UserDefaults.standard.set(true, forKey: hasBeenLaunchedBeforeFlag)
                UserDefaults.standard.synchronize()
            }
            return isFirstLaunch
    }
    
    static func setFirstTime(isNotFirstTime :Bool){
        UserDefaults.standard.set(isNotFirstTime, forKey: "first_time")
    }
    
    
    static func isSubscribe() -> Bool{
        return UserDefaults.standard.bool(forKey: "subscribe")
    }
    
    static func setIsSubscribe(subscribe :Bool){
        UserDefaults.standard.set(subscribe, forKey: "subscribe")
    }
    
    static func logOut()
    {
        API.LOGOUT.startRequest(showIndicator: false) { (Api,response) in
            
        }
        
        MatajerUtility.setIsSubscribe(subscribe: false)
               Messaging.messaging().unsubscribe(fromTopic: API.FIREBASE_SUBSCRIBE_iosArTopic){ error in
                  
                   if error == nil {
                       InstanceID.instanceID().deleteID { (error) in
                                  if error != nil{
                                      print("FIREBASE: ", error.debugDescription);
                                     
                                  } else {
                                      print("FIREBASE: Token Deleted");
                                     MatajerUtility.setIsSubscribe(subscribe: false)
                                     
                                  }
                              }
                     
                   }
               }
  
        UserDefaults.standard.removeObject(forKey: "user")
        MatajerUtility.setNotificationNo(notifcation_number: 0)
        UIApplication.shared.applicationIconBadgeNumber = 0
       
        
    }
    
    static func getNotificationNo() -> Int{
        return UserDefaults.standard.integer(forKey: "unread_notifications")
    }
    
    static func setNotificationNo(notifcation_number: Int){
        return UserDefaults.standard.set(notifcation_number, forKey: "unread_notifications")
    }
    
    
    
    
    
}
