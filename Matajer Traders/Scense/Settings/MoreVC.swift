//
//  MoreVC.swift
//  Matajer Traders
//
//  Created by Heba lubbad on 9/23/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SDWebImage
import IBAnimatable


class MoreVC: UIViewController , WKNavigationDelegate {
    
    
    @IBOutlet var appleView: UIView!
    @IBOutlet var androidView: UIView!
    @IBOutlet var row_imgV: UIImageView!
    @IBOutlet var previewView: UIView!
    @IBOutlet var noti_count_lbl: AnimatableLabel!
    @IBOutlet var userName: UIButton!
    @IBOutlet var userImgV: UIImageView!
    @IBOutlet var menueStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if MatajerUtility.loadUser()?.storeData?.appStore?.count ?? 0 > 1 {
            appleView.isHidden = false
        }else {
            appleView.isHidden = true
        }
        if MatajerUtility.loadUser()?.storeData?.googlePlay?.count  ?? 0 > 1 {
            androidView.isHidden = false
        }else {
            androidView.isHidden = true
        }
        row_imgV.image = Constants.row_down
        userImgV.fetchingImage(url:  MatajerUtility.loadUser()?.storeData?.logo ?? "")
        userName.setTitle(MatajerUtility.loadUser()?.storeData?.nameAr ?? "", for: .normal)
        if MatajerUtility.loadUser()?.notificationAlarm ?? 0 > 0 {
            if MatajerUtility.loadUser()?.notificationAlarm ?? 0 > 99 {
                noti_count_lbl.text = "99+"
            }else{
                noti_count_lbl.text = "\(MatajerUtility.loadUser()?.notificationAlarm ?? 0)"
            }
        }else{
            noti_count_lbl.isHidden = true
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "updateUserInfo"), object: nil, queue: nil) { (notification) in
            self.updateUserData { (result) in
                if result {
                    self.userImgV.fetchingImage(url:  MatajerUtility.loadUser()?.storeData?.logo ?? "")
                    self.userName.setTitle(MatajerUtility.loadUser()?.storeData?.nameAr ?? "", for: .normal)
                }
            }
            
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "updateNotificationNumber"), object: nil, queue: nil) { (notification) in
            if (notification.userInfo as? [String: Any]) != nil
            {
                
                let badge = notification.userInfo?["badge"] as? Int
                
                if badge == 0 {
                    self.noti_count_lbl.isHidden = true
                }else{
                    self.noti_count_lbl.isHidden = false
                    if badge ?? 0 > 99 {
                        self.noti_count_lbl.text = "99+"
                    }else{
                        self.noti_count_lbl.text = "\(badge ?? 0)"
                    }
                    return
                }
            }
            
        }
        
    }
    
    @IBAction func goToNotificationsAction(_ sender: Any) {
         routeNoifications()
     }
    @IBAction func goToSettingsAction(_ sender: Any) {
        self.routeSettings()
    }
    
     
    @IBAction func previewAction(_ sender: Any) {
        if row_imgV.image == Constants.row_down {
            row_imgV.image = Constants.row_up
            previewView.backgroundColor = Constants.LightPrimaryColor
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.view.layoutIfNeeded()
                self?.menueStackView.isHidden = false
            }
            
        }else{
            row_imgV.image = Constants.row_down
            previewView.backgroundColor = .clear
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.view.layoutIfNeeded()
                self?.menueStackView.isHidden = true
            }
            
        }
    }
    @IBAction func contactUsAction(_ sender: Any) {
        let whatsAppNumber =  "\(MatajerUtility.loadUser()?.storeData?.matajerSupportWhatsapp ?? 0)"
        whatsAppNumber.openWhatsApp()
        
    }
    
    @IBAction func openLinkAction(_ sender: Any) {
        
        if let url = URL(string: "\( MatajerUtility.loadUser()?.storeData?.websiteUrl ?? "")"),
            UIApplication.shared.canOpenURL(url)
        {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
    }
    @IBAction func openAppStoreAction(_ sender: Any) {
        
        if let url = URL(string: "itms-apps://itunes.apple.com/app/\( MatajerUtility.loadUser()?.storeData?.appStore ?? "")"),
            UIApplication.shared.canOpenURL(url)
        {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
    }
    
    @IBAction func openGooglePlayAction(_ sender: Any) {
        if let url = URL(string: "\( MatajerUtility.loadUser()?.storeData?.googlePlay ?? "")"),
            UIApplication.shared.canOpenURL(url)
        {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
    }
   
    @IBAction func logoutAction(_ sender: Any) {
        self.singOut()
    }
    
    
}
