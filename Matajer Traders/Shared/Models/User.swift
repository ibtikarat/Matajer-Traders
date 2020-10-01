//
//  User.swift
//  tamween
//
//  Created by Heba lubbad on 7/13/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import Foundation

class User :Codable
{
    
    let allowNotifi : String?
    let apiToken : String?
  //  let birthday : String?
    let createdAt : String?
    let createdAtTimeAgo : String?
    //  let deactivatedAt : String?
    let email : String?
    //    let gender : Int?
    let id : Int?
    let lang : String?
    let mobile : String?
    let name : String?
    let notificationAlarm : Int?
    let showRate : Int?
    // let userFcmToken : [UserFcmToken]?
    let storeData : StoreData?
    
    
    enum CodingKeys: String, CodingKey {
        case allowNotifi = "allow_notifi"
        case apiToken = "api_token"
        //  case birthday = "birthday"
        case createdAt = "created_at"
        case createdAtTimeAgo = "created_at_time_ago"
        // case deactivatedAt = "deactivated_at"
        case email = "email"
        //  case gender = "gender"
        case id = "id"
        case lang = "lang"
        case mobile = "mobile"
        case name = "name"
        case notificationAlarm = "admin_notifications_count"
        case showRate = "show_rate"
        // case userFcmToken = "user_fcm_token"
        case storeData = "store_data"
        
        
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        allowNotifi = try values.decodeIfPresent(String.self, forKey: .allowNotifi)
        apiToken = try values.decodeIfPresent(String.self, forKey: .apiToken)
        //  birthday = try values.decodeIfPresent(String.self, forKey: .birthday)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        createdAtTimeAgo = try values.decodeIfPresent(String.self, forKey: .createdAtTimeAgo)
        // deactivatedAt = try values.decodeIfPresent(String.self, forKey: .deactivatedAt)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        // gender = try values.decodeIfPresent(Int.self, forKey: .gender)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        lang = try values.decodeIfPresent(String.self, forKey: .lang)
        mobile = try values.decodeIfPresent(String.self, forKey: .mobile)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        notificationAlarm = try values.decodeIfPresent(Int.self, forKey: .notificationAlarm)
        showRate = try values.decodeIfPresent(Int.self, forKey: .showRate)
        //  userFcmToken = try values.decodeIfPresent([UserFcmToken].self, forKey: .userFcmToken)
        storeData = try values.decodeIfPresent(StoreData.self, forKey: .storeData)
        
    }
    
}

class UserFcmToken : Codable {
    
    let deviceType : String?
    let fcmToken : String?
    let uuid : String?
    
    enum CodingKeys: String, CodingKey {
        case deviceType = "device_type"
        case fcmToken = "fcm_token"
        case uuid = "uuid"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        deviceType = try values.decodeIfPresent(String.self, forKey: .deviceType)
        fcmToken = try values.decodeIfPresent(String.self, forKey: .fcmToken)
        uuid = try values.decodeIfPresent(String.self, forKey: .uuid)
    }
}
class StoreData : Codable {
    
    let appStore : String?
    let cPanelVersion : String?
    let createdAt : String?
    let customDomain : String?
    let domain : String?
    let googlePlay : String?
    let link : String?
    let logo : String?
    let nameAr : String?
    let nameEn : String?
    let websiteUrl : String?
    let matajerSupportWhatsapp:Int?
    
    enum CodingKeys: String, CodingKey {
        case appStore = "appStore"
        case cPanelVersion = "cPanelVersion"
        case createdAt = "created_at"
        case customDomain = "custom_domain"
        case domain = "domain"
        case googlePlay = "googlePlay"
        case link = "link"
        case logo = "logo"
        case nameAr = "name_ar"
        case nameEn = "name_en"
        case websiteUrl = "websiteUrl"
        case matajerSupportWhatsapp = "matajerSupportWhatsapp"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        appStore = try values.decodeIfPresent(String.self, forKey: .appStore)
        cPanelVersion = try values.decodeIfPresent(String.self, forKey: .cPanelVersion)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        customDomain = try values.decodeIfPresent(String.self, forKey: .customDomain)
        domain = try values.decodeIfPresent(String.self, forKey: .domain)
        googlePlay = try values.decodeIfPresent(String.self, forKey: .googlePlay)
        link = try values.decodeIfPresent(String.self, forKey: .link)
        logo = try values.decodeIfPresent(String.self, forKey: .logo)
        nameAr = try values.decodeIfPresent(String.self, forKey: .nameAr)
        nameEn = try values.decodeIfPresent(String.self, forKey: .nameEn)
        websiteUrl = try values.decodeIfPresent(String.self, forKey: .websiteUrl)
        matajerSupportWhatsapp = try values.decodeIfPresent(Int.self, forKey: .matajerSupportWhatsapp)
    }
    
}
