//
//  MainTabBar.swift
//  tamween
//
//  Created by Heba lubbad on 6/25/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import UIKit

class MainTabBar:  UITabBarController, UITabBarControllerDelegate{
    
    var currentIndexSelected = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        DispatchQueue.main.async {
            let size = CGSize(width: self.tabBar.frame.width / 5,
                              height: self.tabBar.frame.height)
            let image = UIImage.drawTabBarIndicator(color: Constants.PrimaryColor!,
                                                    size: size,
                                                    onTop: false)
            UITabBar.appearance().selectionIndicatorImage = image
            self.tabBar.selectionIndicatorImage = image
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(forName:  NSNotification.Name(rawValue:"GoToOrders"), object: nil, queue: nil) { (notification) in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                if (notification.userInfo as? [String: Any]) != nil
                {
                    self.selectedIndex = 1
                    let id = notification.userInfo?["id"] as? Int
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = (mainStoryboard.instantiateViewController(withIdentifier: "orderDetailsVC") as? orderDetailsVC)!
                    vc.orderId = id
                    if notification.userInfo?["order_number"] != nil {
                        let orderNumber = notification.userInfo?["order_number"] as? String
                        vc.orderNo = orderNumber
                    }
                    let navigationCont = self.selectedViewController as! UINavigationController
                    DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                        navigationCont.pushViewController(vc, animated: true)
                    }
                    
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName:  NSNotification.Name(rawValue:"GoToSuperNotifications"), object: nil, queue: nil) { (notification) in
            self.routeToHome()
        }
        NotificationCenter.default.addObserver(forName:  NSNotification.Name(rawValue:"GoToNotifications"), object: nil, queue: nil) { (notification) in
             DispatchQueue.main.asyncAfter(deadline: .now()) {
              
                     let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                     let vc = (mainStoryboard.instantiateViewController(withIdentifier: "NotificationsVC") as? NotificationsVC)!
                     let navigationCont = self.selectedViewController as! UINavigationController
                     DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                         navigationCont.pushViewController(vc, animated: true)
                     }
              
             }
         }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "updateUserInfo"), object: nil, queue: nil) { (notification) in
            self.updateUserData ()
            }
            
        }

    
    func updateUserData()
    {
        API.GET_USER.startRequest(showIndicator: false) { (api, response) in
            if response.isSuccess {
                let value = response.data as! [String :Any]
                let userData = try! JSONSerialization.data(withJSONObject: value, options: [])
                let user = try! JSONDecoder().decode(User.self, from: userData)
                MatajerUtility.saveUser(user: user)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateUser"), object: self, userInfo: nil)
                
            }
        }
    }
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let selectedIndex = self.selectedIndex
        if selectedIndex == currentIndexSelected {
            switch item.title {
            case "الرئيسية":
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateHome"), object: nil, userInfo: [:])
                break
            case "الطلبات":
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateOrders"), object: nil, userInfo: [:])
                break
            case "المنتجات":
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateProducts"), object: nil, userInfo: [:])
                break
            case "العملاء":
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateCustomers"), object: nil, userInfo: [:])
                break
            default:
                break
            }
        }
        currentIndexSelected = selectedIndex
        
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool{
        
        let nav = viewController as! UINavigationController
        let vc = nav.viewControllers.first
        
        return true
        
    }
    
}


extension UIImage{
    //Draws the top indicator by making image with filling color
    class func drawTabBarIndicator(color: UIColor, size: CGSize, onTop: Bool) -> UIImage {
        let indicatorHeight = size.height
        let yPosition = onTop ? 0 : (size.height - indicatorHeight)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: yPosition, width: size.width, height: 2))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
extension UITabBarController {
    
    
    open override var childForStatusBarStyle: UIViewController? {
        return selectedViewController?.childForStatusBarStyle ?? selectedViewController
    }
}

extension UINavigationController {
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController?.childForStatusBarStyle ?? topViewController
    }
}
