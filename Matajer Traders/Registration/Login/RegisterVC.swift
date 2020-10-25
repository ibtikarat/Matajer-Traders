//
//  RegisterVC.swift
//  tamween
//
//  Created by Heba lubbad on 7/13/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import UIKit
import IBAnimatable

class RegisterVC: UIViewController {
    
 
    @IBOutlet var nextBtn: AnimatableButton!
    @IBOutlet var loader: UIActivityIndicatorView!
    @IBOutlet var passwordTF: AnimatableTextField!
    @IBOutlet var emailTF: AnimatableTextField!
    @IBOutlet var mobileTF: AnimatableTextField!
    @IBOutlet var nameTF: AnimatableTextField!
    @IBOutlet var passwordView: AnimatableView!
    @IBOutlet var emailView: AnimatableView!
    @IBOutlet var mobileView: AnimatableView!
    @IBOutlet var nameView: AnimatableView!
    
    var name:String?
    var mobile:String?
    var email:String?
    var password:String?
    var valid_email:Bool?
    var valid_mobile:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.isHidden = true
     
     
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        emailTF.text = email ?? ""
        nameTF.text = name ?? ""
        passwordTF.text = password ?? ""
        mobileTF.text = mobile ?? ""
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.signIn()
    }
    
    
    @IBAction func registerAction(_ sender: Any)
    {
        switch validationInput()
        {
        case .invalid(let error):
            self.showBunnerAlert(title: "", message: error)
            return
        case .valid:
            self.routeToNextStepAction()
            break
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nextBtn.applyGradient(colours: [Constants.app_gradiant_1 ?? UIColor.black,
                                        Constants.app_gradiant_2 ?? UIColor.black],gradientOrientation :
            .horizontal)
    }
    
    func routeToNextStepAction(){
        loader.isHidden = false
        loader.startAnimating()
        let mainStoryboard = UIStoryboard(name: "Registration", bundle: nil)
        let vc = (mainStoryboard.instantiateViewController(withIdentifier: "Register2VC") as? Register2VC)!
        vc.fullName = nameTF.text
        vc.email = emailTF.text
        vc.password = passwordTF.text
        vc.mobile = mobileTF.text
        name  = nameTF.text
        email = emailTF.text
        password = passwordTF.text
        mobile =  mobileTF.text
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loader.isHidden = true
            self.loader.stopAnimating()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @IBAction func showHidePwdAction(_ sender: UIButton)
    {
        if passwordTF.isSecureTextEntry {
            passwordTF.isSecureTextEntry = false
            sender.setImage(Constants.eye_enabled, for: .normal)
        }else {
            passwordTF.isSecureTextEntry = true
            sender.setImage(Constants.eye_disabled, for: .normal)
        }
    }
    
    
    func validationInput() -> Validation{
        
        
        if nameTF.text!.isEmpty {
            
            return .invalid("حقل الإسم مطلوب")
        }
        
        if nameTF.text!.count < 5 {
            
            return .invalid("الرجاء إضافة الإسم الأول و الأخير")
        }
        
        if mobileTF.text?.isEmpty ?? true  ||  !mobileTF.text!.ValidateMobileNumber() {
            
            return .invalid("مطلوب 10أرقام رقم الجوال ********05")
        }
        if ( emailTF.text?.isEmpty ?? true ||  !emailTF.text!.isEmailValid )  {
            return .invalid("يجب إدخال البريد بشكل صحيح")
        }
        if passwordTF.text!.isEmpty {
            
            return .invalid("حقل كملة المرور مطلوب")
        }
        if passwordTF.text!.count < 6 {
            
          
        }
        if !(valid_email ?? false ){
            return .invalid("البريد الإلكتروني مسجل مسبقاً")
            }
        if !(valid_mobile ?? false) {
            return .invalid("رقم الجوال مسجل مسبقاً")
        }
        return .valid
    }
    
    
}


extension RegisterVC : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch textField {
        case emailTF:
            emailView.borderColor = Constants.PrimaryColor
            emailView.borderWidth = 1
            
        case passwordTF:
            passwordView.borderColor = Constants.PrimaryColor
            passwordView.borderWidth = 1
        case mobileTF:
            mobileView.borderColor = Constants.PrimaryColor
            mobileView.borderWidth = 1
        case nameTF:
            nameView.borderColor = Constants.PrimaryColor
            nameView.borderWidth = 1
            
        default:
            return
        }
        
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTF:
            emailView.borderColor = .clear
            emailView.borderWidth = 0
            email  = emailTF.text
            if emailTF.text!.isEmailValid  {
               checkEmailMobile(value: email ?? "")
            }
        case passwordTF:
            passwordView.borderColor = .clear
            passwordView.borderWidth = 0
            
        case mobileTF:
            mobileView.borderColor = .clear
            mobileView.borderWidth = 0
            mobile =  mobileTF.text
            if mobileTF.text!.ValidateMobileNumber() {
               checkEmailMobile(value: mobile ?? "")
            }
        case nameTF:
            nameView.borderColor = .clear
            nameView.borderWidth = 0
            
        default:
            return true
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case emailTF:
            emailView.borderColor = .clear
            emailView.borderWidth = 0
            email  = emailTF.text
            if emailTF.text!.isEmailValid  {
               checkEmailMobile(value: email ?? "")
            }
        case passwordTF:
            passwordView.borderColor = .clear
            passwordView.borderWidth = 0
        case mobileTF:
            mobileView.borderColor = .clear
            mobileView.borderWidth = 0
            mobile =  mobileTF.text
            if mobileTF.text!.ValidateMobileNumber() {
              checkEmailMobile(value: mobile ?? "")
            }
        case nameTF:
            nameView.borderColor = .clear
            nameView.borderWidth = 0
            
        default:
            return 
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch textField {
            
        case mobileTF:
            
            if let char = string.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                if (isBackSpace == -92) {
                return true
                }
            }
           return  checkMaxLength(textField: mobileTF, maxLength: 9)
            
            
        default:
            return true
        }
        
        return true
    }
    

    
    func checkEmailMobile(value:String) {
        
        
        var params = [String:String]()
        params["txt"] = value
        API.CHECK_MOBILE_EMAIL.startRequest(showIndicator: false, params: params) { (Api,response) in
            if response.isSuccess {
                if value.isEmailValid {
                   
                    self.valid_email = true
                } else if value.ValidateMobileNumber() {
                   
                    self.valid_mobile = true
                }
                
            }else{
                if value.isEmailValid {
                    self.showBunnerAlert(title: "", message:"البريد الإلكتروني مسجل مسبقاً")
                    self.valid_email = false
                } else if value.ValidateMobileNumber() {
                    self.showBunnerAlert(title: "", message: "رقم الجوال مسجل مسبقاً")
                    self.valid_mobile = false
                }
               
             

            }
        }
       
    }
    
}
