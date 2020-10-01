//
//  ForegetPwdVC.swift
//  tamween
//
//  Created by Heba lubbad on 7/14/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import UIKit
import IBAnimatable
import MOLH




class ForegetPwdVC: UIViewController {
    
    @IBOutlet var loader: UIActivityIndicatorView!
    @IBOutlet var emailView: AnimatableView!
    @IBOutlet var emailTF: AnimatableTextField!
    
    @IBOutlet var sentBtn: AnimatableButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.isHidden = true
        if MOLHLanguage.isRTLLanguage() {
            emailTF.textAlignment = .right
        }else {
            emailTF.textAlignment = .left
        }
    }
    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           sentBtn.applyGradient(colours: [Constants.app_gradiant_1 ?? UIColor.black,
                                                 Constants.app_gradiant_2 ?? UIColor.black],gradientOrientation :
               .horizontal)
       }
    
    @IBAction func nextAction(_ sender: Any)
    {
        switch validationInput() {
        case .invalid(let error):
            self.showBunnerAlert(title: "", message: error)
            
        case .valid:
            startRequest()
            break
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    
    func validationInput() -> Validation{
        
        
        if ( emailTF.text?.isEmpty ?? true ||  !emailTF.text!.isEmailValid )  {
            return .invalid("يجب إدخال بريد إلكتروني فعال")
        }
        
        return .valid
    }
    
    func startRequest(){
        
        var params = [String:String]()
        params["email"] = emailTF.text ?? ""
        
        self.loader.isHidden = false
        self.loader.startAnimating()
        API.FORGET.startRequest(showIndicator: true, params: params) { (Api,response) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.loader.isHidden = true
                self.loader.stopAnimating()
            }
            if response.isSuccess {
                self.showBunnerSuccessAlert(title: "", message: response.message)
                let mainStoryboard = UIStoryboard(name: "Registration", bundle: nil)
                let vc :ResetPwdVC = mainStoryboard.instanceVC()
                vc.forgetPwdEmail = self.emailTF.text ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else{
                self.showBunnerAlert(title: "", message: response.message)
            }
        }
    }
    
    
}

extension ForegetPwdVC : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch textField {
        case emailTF:
            emailView.borderColor = Constants.PrimaryColor
            emailView.borderWidth = 1
            
        default:
            return
        }
        
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTF:
            emailView.borderColor = .clear
            emailView.borderWidth = 0
            
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
            
        default:
            return
        }
        
    }
}




