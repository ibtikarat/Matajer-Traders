//
//  StatusResult.swift
//  Smart Safty
//
//  Created by ayyad on 7/10/2019.
//  Copyright © 2017 Monal.im. All rights reserved.
//

import Foundation
class StatusResult {
    private var status :Bool
    var statusCode :Int?
    
    //if have more issue from server
    private var errors : [String] = []
    
    //if have one Single from server
    var message : String = ""

    var data : Any

    var isSuccess :Bool {
        get{
          return status
        }
        set{
            status = newValue
        }
    }
    
    var errorMessege :String{
        get{
            if errors.isEmpty {
                return message
            }
            
            
            var errorMessage :String = ""
            if errors.isEmpty {
                errorMessage.append(message)
            }
            for value in errors {
                errorMessage.append(contentsOf: value + "\n")
                
            }
            
            return errorMessage
        }
        
        set{
            errors.append(newValue)
        }
    }
    
    init(json: [String:Any]){
         status = json["status"] as? Bool ?? false
         errors = json["errors"] as? [String] ?? []
         message = json["message"] as? String ?? ""
         statusCode = json["status_code"] as? Int ?? 0

        
         data  = json["items"] ?? json
        
        
        
    }
   
}






