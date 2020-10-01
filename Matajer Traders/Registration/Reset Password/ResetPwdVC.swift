//
//  ResetPwdVC.swift
//  tamween
//
//  Created by Heba lubbad on 7/14/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import UIKit
import IBAnimatable

class ResetPwdVC: UIViewController {
    
    @IBOutlet var codeView: AnimatableView!
    @IBOutlet var codeTF: AnimatableTextField!
    @IBOutlet var loader: UIActivityIndicatorView!
    @IBOutlet var confirmPwdView: AnimatableView!
    @IBOutlet var confrimPwdTF: AnimatableTextField!
    @IBOutlet var pwdTF: AnimatableTextField!
    @IBOutlet var pawdView: AnimatableView!
    
    var code = ""
    var forgetPwdEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.isHidden = true
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    
    
    @IBAction func showHidePwdAction(_ sender: UIButton) {
        if sender.tag ==  1 {
            if pwdTF.isSecureTextEntry {
                pwdTF.isSecureTextEntry = false
                sender.setImage(Constants.eye_enabled, for: .normal)
            }else {
                pwdTF.isSecureTextEntry = true
                sender.setImage(Constants.eye_disabled, for: .normal)
            }
        }else {
            if confrimPwdTF.isSecureTextEntry {
                confrimPwdTF.isSecureTextEntry = false
                sender.setImage(Constants.eye_enabled, for: .normal)
            }else {
                confrimPwdTF.isSecureTextEntry = true
                sender.setImage(Constants.eye_disabled, for: .normal)
            }
        }
    }
    
    @IBAction func confirmAction(_ sender: Any)
    {
        switch validationInput() {
        case .invalid(let error):
            self.showBunnerAlert(title: "", message: error)
            
        case .valid:
            startRequest()
            break
        }
    }
    
    func validationInput() -> Validation{
        
        if pwdTF.text!.isEmpty {
            
             return .invalid("حقل كملة المرور مطلوب")
        }
        if pwdTF.text!.count < 6 {
            
           return .invalid("مطلوب 6 خانات على الأقل")
        }
        if confrimPwdTF.text!.isEmpty {
            
             return .invalid("حقل تأكيد كملة المرور مطلوب")
        }
        if confrimPwdTF.text!.count < 6 {
            
            return .invalid("مطلوب 6 خانات على الأقل")
        }
        if confrimPwdTF.text! != pwdTF.text!  {
            
            return .invalid("كلمتان المرور غير متطابقتان")
        }
        return .valid
    }
    
    func startRequest(){
        
        var params = [String:String]()
        params["email"] = forgetPwdEmail
        params["code"] = codeTF.text ?? ""
        params["password"] = pwdTF.text
        params["password_confirmation"] = confrimPwdTF.text
        
        self.loader.isHidden = false
        self.loader.startAnimating()
        API.RESET_PASSWORD.startRequest(showIndicator: true, params: params) { (Api,response) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.loader.isHidden = true
                self.loader.stopAnimating()
            }
            if response.isSuccess {
                self.showBunnerSuccessAlert(title: "", message: response.message)
                self.signIn()
                
            }
            else
            {
                self.showBunnerAlert(title: "", message: response.message)
            }
        }
    }
    
    
    
}


extension ResetPwdVC : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch textField {
        case codeTF:
            codeView.borderColor = Constants.PrimaryColor
            codeView.borderWidth = 1
        case pwdTF:
            pawdView.borderColor = Constants.PrimaryColor
            pawdView.borderWidth = 1
        case confrimPwdTF:
            confirmPwdView.borderColor = Constants.PrimaryColor
            confirmPwdView.borderWidth = 1
            
            
        default:
            return
        }
        
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case codeTF:
            codeView.borderColor = .clear
            codeView.borderWidth = 0
        case pwdTF:
            pawdView.borderColor = .clear
            pawdView.borderWidth = 0
        case confrimPwdTF:
            confirmPwdView.borderColor = .clear
            confirmPwdView.borderWidth = 0
            
        default:
            return true
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case codeTF:
            codeView.borderColor = .clear
            codeView.borderWidth = 0
        case pwdTF:
            pawdView.borderColor = .clear
            pawdView.borderWidth = 0
        case confrimPwdTF:
            confirmPwdView.borderColor = .clear
            confirmPwdView.borderWidth = 0
            
            
        default:
            return
        }
    }
    
    
}

