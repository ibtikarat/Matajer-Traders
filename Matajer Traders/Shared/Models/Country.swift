//
//  Country.swift
//  Matajer
//
//  Created by Heba lubbad on 11/8/20.
//  Copyright © 2020 Abdullah Ayyad. All rights reserved.
//

import UIKit
import Foundation

class CountryApp: NSObject,Codable {
    
    
    
    let id : Int?
    let img : String?
    let mobileDigits : Int?
    let name : String?
    let prefix : Int?
    let realMobile : Int?
    let code : String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case img = "image"
        case mobileDigits = "mobile_digits"
        case name = "name"
        case prefix = "prefix"
        case realMobile = "real_mobile"
        case code = "code"
    }
    
    
}
