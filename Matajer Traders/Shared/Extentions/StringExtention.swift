//
//  StringExtention.swift
//  tamween
//
//  Created by Heba lubbad on 7/13/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import Foundation
import UIKit

extension String
{
var localized: String {
       return NSLocalizedString(self, comment: self) //NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
   }
    
    var isEmailValid: Bool {
           do {
               let regex = try NSRegularExpression(pattern: "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])", options: .caseInsensitive)
               return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
           } catch {
               return false
           }
       }
       
    var valueWithCurrency :String{
           get{
               return self + " " + (AppDelegate.shared.language == "ar" ? "ر.س" : "SAR")
           }
       }
       
       
       
       var htmlAttributedString : NSAttributedString? {
           
           get{
              guard let data = self.data(using: String.Encoding.utf16, allowLossyConversion: false) else { return nil }
              guard let html = try? NSMutableAttributedString(
                  data: data,
                  options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                  documentAttributes: nil) else { return nil }
              return html
           }
          }
       
       
       var Pricing : String{
       
       let val = Double(self)
           if val?.fraction ==  0.00{
               return "\(String(format:"%.0f",val ?? 0.0))"
           }else {
                return "\(String(format:"%.02f",val ?? 0.0))"
           }

       }
       
    
       func ValidateMobileNumber() -> Bool {

             let formatePre = "^((\\+)|(05))[0-9]{8}$"
                   let resultPredicate : NSPredicate = NSPredicate(format: "SELF MATCHES %@",formatePre)
                   return resultPredicate.evaluate(with: self)
         }
    
    
    static func changeFormat(dateString: String ,toFormat: String = "dd MMM yyyy") -> String{
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = toFormat
        
        return formatter.string(from: Date.convertToDate(date: dateString))
    }
    static func convertToDate(date :String,formatText :String = "yyyy-MM-dd") -> Date{
          let formatter = DateFormatter()
           formatter.dateFormat = formatText
           return formatter.date(from: date) ?? Date()
        }
           func openWhatsApp()
           {
               var whatsAppNumber = "\(self)"
                      if whatsAppNumber.contains("+") {
                          whatsAppNumber.removeFirst()
                      }
                      guard let whatsAppUrl = URL(string: "whatsapp://send?phone=\(whatsAppNumber)&text="),
                          case let application = UIApplication.shared, application.canOpenURL(whatsAppUrl)
                          else {
                              return
                      }
                      
                      UIApplication.shared.open(whatsAppUrl, options: [:], completionHandler: nil)
           }
    
    func ValidateMobileNumber(maxLenght:Int) -> Bool {

        let formatePre = "^[0-9]{\(maxLenght)}$"
    
        let valid = NSPredicate(format: "SELF MATCHES %@", formatePre).evaluate(with: self)
        print(valid)
              return valid
      
    }

}
