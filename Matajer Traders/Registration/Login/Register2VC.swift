//
//  Register2VC.swift
//  Matajer Traders
//
//  Created by Heba lubbad on 9/16/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import UIKit
import IBAnimatable
import DropDown
import Firebase

class Register2VC: UIViewController {
    
    @IBOutlet var topImgv: UIImageView!
    @IBOutlet var availableLbl: AnimatableLabel!
    @IBOutlet var appLinkLbl: AnimatableLabel!
    @IBOutlet var haveTradeBtn: UIButton!
    @IBOutlet var sourceRegistrationTF: AnimatableTextField!
    @IBOutlet var otherView: AnimatableView!
    @IBOutlet var otherTF: AnimatableTextField!
    @IBOutlet var loader: UIActivityIndicatorView!
    @IBOutlet var enNameTF: AnimatableTextField!
    @IBOutlet var arNameTF: AnimatableTextField!
    @IBOutlet var arNameView: AnimatableView!
    @IBOutlet var enNameView: AnimatableView!
    var fullName:String?
    var mobile:String?
    var email:String?
    var password:String?
    var source:String?
    var link:String?
    var checked = false
    @IBOutlet var registerBtn: AnimatableButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.isHidden = true
        
        enNameTF.keyboardType = .alphabet
        otherView.visibility = .gone
        availableLbl.visibility = .gone
        appLinkLbl.visibility = .gone
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        registerBtn.applyGradient(colours: [Constants.app_gradiant_1 ?? UIColor.black,
                                            Constants.app_gradiant_2 ?? UIColor.black],gradientOrientation :
            .horizontal)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    @IBAction func goToLoginAction(_ sender: Any) {
        self.signIn()
    }
    @IBAction func select_registration_sourceAction(_ sender: UIButton) {
        let DropDown = showDropDownMenu(button: sender, width: sender.bounds.width)
        DropDown.semanticContentAttribute =  .forceRightToLeft
        DropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            
            cell.optionLabel.textAlignment = .right
            
        }
        DropDown.dataSource = ["محركات  البحث",
                               "إنستجرام",
                               "واتس أب",
                               "سناب شات",
                               "تويتر",
                               "يوتيوب",
                               "صديق",
                               "أخرى"]
        
        DropDown.selectionAction = { [weak self] (index, item) in
            switch index {
            case 0:
                self?.sourceRegistrationTF.text = "محركات البحث"
                self?.source = "search_engines"
                self?.otherView.visibility = .gone
            case 1:
                self?.sourceRegistrationTF.text = "إنستجرام"
                self?.source = "instagram"
                self?.otherView.visibility = .gone
            case 2:
                self?.sourceRegistrationTF.text = "واتس أب"
                self?.source = "whatsapp"
                self?.otherView.visibility = .gone
            case 3:
                self?.sourceRegistrationTF.text = "سناب شات"
                self?.source = "snapchat"
                self?.otherView.visibility = .gone
            case 4:
                self?.sourceRegistrationTF.text = "تويتر"
                self?.source = "twitter"
                self?.otherView.visibility = .gone
            case 5:
                self?.sourceRegistrationTF.text = "يوتيوب"
                self?.source = "youtube"
                self?.otherView.visibility = .gone
            case 6:
                self?.sourceRegistrationTF.text = "صديق"
                self?.source = "friend"
                self?.otherView.visibility = .gone
            case 7:
                self?.sourceRegistrationTF.text = "أخرى"
                self?.source = "other"
                self?.otherView.visibility = .visible
            default:
                break
            }
            
        }
        DropDown.dismissMode = .onTap
        DropDown.direction = .bottom
        
        DropDown.show()
        
    }
    
    @IBAction func isHaveTradeAction(_ sender: UIButton) {
        if !checked {
            self.haveTradeBtn.setImage(UIImage(named: "switch_on"), for: .normal)
            self.haveTradeBtn.tintColor = Constants.PrimaryColor
        }else {
            self.haveTradeBtn.setImage(UIImage(named: "switch_off"), for: .normal)
            self.haveTradeBtn.tintColor = Constants.LightPrimaryColor
            
        }
        checked.toggle()
        
    }
    @IBAction func registerAction(_ sender: Any) {
        switch validationInput()
        {
        case .invalid(let error):
            self.showBunnerAlert(title: "", message: error)
        case .valid:
            self.startRegister()
            break
        }
    }
    
    func validationInput() -> Validation{
        
        
        if enNameTF.text!.isEmpty {
            
            return .invalid("يجب إدخال اسم المتجر باللغة الإنجليزية")
        }
        
        if enNameTF.text!.count < 3 {
            
            return .invalid("يجب ادخال اسم صحيح للمتجر باللغة الإنجليزية")
        }
        
        if arNameTF.text!.isEmpty {
            
            return .invalid("يجب إدخال اسم المتجر باللغة العربية")
        }
        
        if arNameTF.text!.count < 3 {
            
            return .invalid("يجب ادخال اسم صحيح للمتجر باللغة العربية")
        }
        
        if sourceRegistrationTF.text!.isEmpty {
            
            return .invalid("الرجاء اختيار طريقة سماعك عن متاجر")
        }
        if source == "other" &&  otherTF.text!.isEmpty {
            return .invalid("الرجاء أضافة طريقة معرفتك بمتاجر")
        }
        
        
        return .valid
    }
    
    
    func startRegister(){
        loader.isHidden = false
        loader.startAnimating()
        
        var params = [String:String]()
        params["name"] = fullName ?? ""
        params["email"] = email ?? ""
        params["mobile"] = mobile ?? ""
        params["password"] = password ?? ""
        params["link"] = enNameTF.text ?? ""
        params["name_ar"] = arNameTF.text ?? ""
        params["registration_source"] = source ?? ""
        params["registration_other_content"] = otherTF.text ?? ""
        params["have_trade"] = checked ? "1" : "0"
        params["fcm_token"] =  UserDefaults.standard.string(forKey: "fcmToken") ?? ""
        params["device_type"] = "ios"
        params["uuid"] = UIDevice.current.identifierForVendor?.uuidString
        
        API.REGISTER.startRequest(showIndicator: true, params: params) { (Api,response) in
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
                    Messaging.messaging().subscribe(toTopic: (user.storeData?.ios_popup_topic!)!) { error in
                                    if error == nil {
                                        
                                        print("Subscribed to ios Topic Package")
                                    }
                                }
                }
                
                
                self.routeToHome()
            }else{
                self.loader.isHidden = true
                self.loader.stopAnimating()
                
                self.showBunnerAlert(title: "", message: response.errorMessege)
            }
        }
    }
    
}
extension Register2VC : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch textField {
        case enNameTF:
            enNameView.borderColor = Constants.PrimaryColor
            enNameView.borderWidth = 1
        case arNameTF:
            arNameView.borderColor = Constants.PrimaryColor
            arNameView.borderWidth = 1
        case otherTF:
            otherView.borderColor = Constants.PrimaryColor
            otherView.borderWidth = 1
            
            
        default:
            return
        }
        
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case enNameTF:
            enNameView.borderColor = .clear
            enNameView.borderWidth = 0
            link  = enNameTF.text
            if link?.count  ?? 0 > 2 {
                checkLink()
            }
        case arNameTF:
            arNameView.borderColor = .clear
            arNameView.borderWidth = 0
        case otherTF:
            otherView.borderColor = .clear
            otherView.borderWidth = 0
            
            
        default:
            return true
        }
        
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case enNameTF:
            enNameView.borderColor = .clear
            enNameView.borderWidth = 0
            link  = enNameTF.text
            if link?.count  ?? 0 > 2 {
                checkLink()
            }
            return
        case arNameTF:
            arNameView.borderColor = .clear
            arNameView.borderWidth = 0
        case otherTF:
            otherView.borderColor = .clear
            otherView.borderWidth = 0
            
        default:
            return
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var isBackSpace_Pressed = false
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92) {
                isBackSpace_Pressed = true
            }
        }
        var str = ""
        
        switch textField {
            
        case enNameTF:
            if isBackSpace_Pressed {
                str = "\(enNameTF.text ?? "")"
                str.removeLast()
                print("link after backspace \(str )")
            }else {
                str = "\(enNameTF.text ?? "")\(string)"
            }
            if str.count > 2  {
                link = str
                self.checkLink()
            }else {
                self.availableLbl.visibility = .gone
                self.appLinkLbl.visibility = .gone
                
            }
            
            
            
        default:
            return true
        }
        
        return true
    }
    
    func checkLink(){
        
        var params = [String:String]()
        params["link"] = link
        API.CHECK_LINK.startRequest(showIndicator: false, params: params) { (Api,response) in
            if response.isSuccess {
                self.enNameTF.text = self.link ?? ""
                self.availableLbl.visibility = .visible
                self.appLinkLbl.visibility = .visible
                self.appLinkLbl.text = "رابط متجرك سيكون بالشكل التالي: https://mapp.sa/\(self.link ?? "")"
                
                
            }else{
                self.availableLbl.visibility = .gone
                self.appLinkLbl.visibility = .gone
                
                self.showBunnerAlert(title: "", message: response.errorMessege)
            }
        }
    }
    
    
}
