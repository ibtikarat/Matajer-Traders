//
//  LoginVC.swift
//  tamween
//
//  Created by Heba lubbad on 6/25/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import UIKit
import IBAnimatable
import Firebase

class LoginVC: UIViewController  {
    
    
    
    
    
    @IBOutlet var loader: UIActivityIndicatorView!
    @IBOutlet var loginBtn: AnimatableButton!
    @IBOutlet var pwdTF: UITextField!
    @IBOutlet var mobileEmailTF: UITextField!
    @IBOutlet var pwdView: AnimatableView!
    @IBOutlet var mobileEmailView: AnimatableView!
    
    var type = "email"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.isHidden = true
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loginBtn.applyGradient(colours: [Constants.app_gradiant_1 ?? UIColor.black,
                                         Constants.app_gradiant_2 ?? UIColor.black],gradientOrientation :
                                            .horizontal)
    }
    
    @IBAction func forgetPwdAction(_ sender: Any)
    {
        let mainStoryboard = UIStoryboard(name: "Registration", bundle: nil)
        let vc :ForegetPwdVC = mainStoryboard.instanceVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    @IBAction func loginAction(_ sender: Any)
    {
        switch validationInput() {
        case .invalid(let error):
            self.showBunnerAlert(title: "", message: error)
            
        case .valid:
            startLogin()
            break
        }
    }
    
    
    
    @IBAction func showHidePwdAction(_ sender: UIButton) {
        if pwdTF.isSecureTextEntry {
            pwdTF.isSecureTextEntry = false
            sender.setImage(Constants.eye_enabled, for: .normal)
        }else {
            pwdTF.isSecureTextEntry = true
            sender.setImage(Constants.eye_disabled, for: .normal)
        }
    }
    
    func startLogin(){
        
        var params = [String:String]()
        params["username"] = mobileEmailTF.text ?? ""
        params["password"] = pwdTF.text ?? ""
        params["fcm_token"] =  UserDefaults.standard.string(forKey: "fcmToken") ?? ""
        params["device_type"] = "ios"
        params["uuid"] = UIDevice.current.identifierForVendor?.uuidString
        
        
        loader.startAnimating()
        loader.isHidden = false
        API.LOGIN.startRequest(showIndicator: true, params: params) { (Api,response) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.loader.isHidden = true
                self.loader.stopAnimating()
            }
            if response.isSuccess {
                
                let value = response.data as! [String :Any]
                let userData = try! JSONSerialization.data(withJSONObject: value, options: [])
                let user = try! JSONDecoder().decode(User.self, from: userData)
                MatajerUtility.saveUser(user: user)
                
                Messaging.messaging().subscribe(toTopic: API.FIREBASE_SUBSCRIBE_iosArTopic) { error in
                    if error == nil {
                        
                        print("Subscribed to iosArTopic topic")
                    }
                }
                
                Messaging.messaging().subscribe(toTopic: API.FIREBASE_SUBSCRIBE_iosTopic) { error in
                    if error == nil {
                        
                        print("Subscribed to ios Topic topic")
                    }
                }
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
                
                
                MatajerUtility.setNotificationNo(notifcation_number:user.notificationAlarm ?? 0)
                UIApplication.shared.applicationIconBadgeNumber = user.notificationAlarm ?? 0
                
                self.routeToHome()
                
            }else{
                self.showBunnerAlert(title: "", message: response.message)
            }
        }
        
    }
    
    func validationInput() -> Validation{
        
        if mobileEmailTF.text?.isEmpty ?? true  {
            
            return .invalid("حقل الإيميل / رقم الجوال مطلوب")
        }
        let num = Int(mobileEmailTF.text ?? "")
        if num != nil {
            if !(mobileEmailTF.text?.ValidateMobileNumber() ?? false) {
                return .invalid("مطلوب 10أرقام رقم الجوال ********05")
            }
        }else {
            if !mobileEmailTF.text!.isEmailValid {
                return .invalid("يجب إدخال البريد بشكل صحيح".localized)
            }
        }
        
        if pwdTF.text!.isEmpty {
            
            return .invalid("حقل كملة المرور مطلوب")
        }
        if pwdTF.text!.count < 6 {
            
            return .invalid("مطلوب 6 خانات على الأقل")
        }
        return .valid
    }
    
    
    
}

extension LoginVC : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch textField {
        case mobileEmailTF:
            mobileEmailView.borderColor = Constants.PrimaryColor
            mobileEmailView.borderWidth = 1
        case pwdTF:
            pwdView.borderColor = Constants.PrimaryColor
            pwdView.borderWidth = 1
            
        default:
            return
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case mobileEmailTF:
            mobileEmailView.borderColor = .clear
            mobileEmailView.borderWidth = 0
        case pwdTF:
            pwdView.borderColor = .clear
            pwdView.borderWidth = 0
        default:
            return true
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case mobileEmailTF:
            mobileEmailView.borderColor = .clear
            mobileEmailView.borderWidth = 0
        case pwdTF:
            pwdView.borderColor = .clear
            pwdView.borderWidth = 0
        default:
            return
        }
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch textField {
        
        case mobileEmailTF:
            let num = Int(mobileEmailTF.text ?? "")
            if num != nil {
                if let char = string.cString(using: String.Encoding.utf8) {
                    let isBackSpace = strcmp(char, "\\b")
                    if (isBackSpace == -92) {
                        return true
                    }
                }
                return   checkMaxLength(textField: mobileEmailTF, maxLength: 9)
            }
            
        default:
            return true
        }
        
        return true
    }
}

