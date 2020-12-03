//
//  API.swift
//  tamween
//
//  Created by Heba lubbad on 7/13/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

enum API {
    
    private static let DEBUG = true
    private  static let TAG = "API - Service "
    
    
    static let DOMAIN_URL = "https://matajerapp.dev/api/merchant/v1/";
    static var FIREBASE_SUBSCRIBE_iosArTopic = "merchantapp"
     static let FIREBASE_SUBSCRIBE_iosTopic = "iosMerchantAppPopup";
    
   
    
    case HOME
    
    case GET_USER
   

    //auth
    case CHECK_LINK
    case CHECK_MOBILE_EMAIL
    case LOGIN
    case REGISTER
    case FORGET
    case ACTIVATE
    case RESET_PASSWORD
    case LOGOUT

    
    private var values : (url: String ,reqeustType: HTTPMethod,key :String?)
    {
        get
        {
            switch self {
                
           
                
            case .GET_USER:
                return (API.DOMAIN_URL + "info",.get,nil)
            
                case .CHECK_LINK:
                             return (API.DOMAIN_URL + "checkLink",.post,nil)
                
            case .LOGIN:
                return (API.DOMAIN_URL + "login",.post,nil)
                
            case .REGISTER:
                return (API.DOMAIN_URL + "register",.post,nil)
                
            case .FORGET:
                return (API.DOMAIN_URL + "password/forgot",.post,nil)
                
            case .ACTIVATE:
                return (API.DOMAIN_URL + "find",.post,nil)
                
            case .RESET_PASSWORD:
                return (API.DOMAIN_URL + "password/reset",.put,nil)
                
            case .LOGOUT:
                return (API.DOMAIN_URL + "logout",.get,nil)
                
            case .HOME:
                return (API.DOMAIN_URL + "home",.get,nil)
                
            case .CHECK_MOBILE_EMAIL:
                return (API.DOMAIN_URL + "checkEmailOrMobile",.post,nil)
                
            }
        }
    }
    
    
    
    
        func startRequest(uiViewController:UIViewController? = nil,showIndicator:Bool = false ,nestedParams :String = "",params :[String:String] = [:],header : [String:String] = [:],completion : @escaping (API,StatusResult)->Void){
            var params = params;
            var header = header
            var nestedParams = nestedParams
            
            header["Accept"] = "application/json"
            header["Accept-Language"] = AppDelegate.shared.language
            
            if let authToken = MatajerUtility.loadUser()?.apiToken {
                header["Authorization"] = "Bearer \(authToken)"
               
            }
            
            
            
            var httpHeader = HTTPHeaders(header)
            if API.DEBUG {
                printRequest(nested: nestedParams,params: params, header: header)
            }
            
            let currentViewCountroller = AppDelegate.shared.viewController
            
            currentViewCountroller.isInterntConnected(){_ in
                self.startRequest(nestedParams:nestedParams,params: params, completion:completion)
            }
            
            //        if showIndicator{
            //            currentViewCountroller.showIndicator()
            //        }
            
            startRequest(api: self,nestedParams: nestedParams,params: params,header: httpHeader) { (result,status,message) in
                if API.DEBUG {
                    self.printResponse(result: result)
                }
                
              
                let statusResult = StatusResult(json: result)
                
                if !status {
                    statusResult.isSuccess = status
                    statusResult.errorMessege = message
                }
                
                
                if statusResult.statusCode == 401 {
                    currentViewCountroller.singOutWithPermently(message: statusResult.errorMessege)
                }else{
                    completion(self,statusResult)
                }
            }
        }
        
        private func printRequest(nested :String, params :[String:String] = [:],header : [String:String] = [:]){
            print(API.TAG + "url : \(self.values.url)/\(nested)" )
            print(API.TAG + "params : \(params)" )
            print(API.TAG + "header : \(header)" )
            
        }
        
        private func printResponse(result: [String:Any]) {
            print(API.TAG + "result : \(result)" )
        }
        
        
        private func startRequest(api :API,nestedParams :String = "",params : [String:String] = [:],header: HTTPHeaders = [:], completion:@escaping ([String:Any],Bool,String)->Void){
            
            AF.request(api.values.url+nestedParams, method: api.values.reqeustType, parameters: params.isEmpty ? nil:params,encoding: URLEncoding.default, headers: header.isEmpty ? nil:header)
                //.validate(statusCode: 200..<600)
                .responseJSON { response  in
                    if API.DEBUG {
                        if let statusCode = response.response?.statusCode {
                            print(API.TAG + "status code : \(statusCode)" )
                        }
                    }
                    
                    switch(response.result)
                    {
                    case .success(let value):
                        if API.DEBUG {
                            let res = JSON(value)
                            print(res)
                        }
                        if let resp = value as? [String:Any] {
                            completion(resp,true,"")
                        }else {
                            completion([:],false,"no data was found in response")
                        }
                        if API.DEBUG {
                            debugPrint(value)
                        }
                    case .failure(let error) :
                        if API.DEBUG {
                            print(response.error.debugDescription)
                            print(error.errorDescription)
                            
                        }
                        completion([:],false,error.localizedDescription)
                    }
                    
            }
        }
        
        
        
        
        
        ///file
        
        func startRequestWithFile(uiViewController:UIViewController? = nil,showIndicator:Bool = false,nestedParams :String = "" ,params :[String:String] = [:],data :[String:Data] = [:],headers : [String:String] = [:],completion : @escaping (API,StatusResult)->Void){
            var params = params;
            var headers = headers;
            
            headers["Accept"] = "application/json"
            headers["Accept-Language"] = AppDelegate.shared.language
            
            if let authToken = MatajerUtility.loadUser()?.apiToken {
                headers["Authorization"] = "Bearer \(authToken)"
            }
            
            
            
            if API.DEBUG {
                printRequest(nested: nestedParams, params: params, header: headers)
                print("data size 'file Numbers' \(data.count)")
                
            }
            
            let currentViewCountroller = AppDelegate.shared.viewController
            
            if  !currentViewCountroller.isConnectedToNetwork() {
                currentViewCountroller.isInterntConnected(){_ in
                    self.startRequest(params: params, completion:completion)
                }
                return
            }
            
            
            if showIndicator{
                currentViewCountroller.showIndicator()
            }
            
            startRequest(api: self,nestedParams :nestedParams ,params: params,data: data,headers: HTTPHeaders(headers)) { (result,status,message) in
                if API.DEBUG {
                    self.printResponse(result: result)
                }
                
                if showIndicator{
                    currentViewCountroller.hideIndicator()
                }
                
                let statusResult = StatusResult(json: result)
                
                if !status {
                    statusResult.isSuccess = status
                    statusResult.errorMessege = message
                }
                completion(self,statusResult)
            }
        }
        
        
        
        
        private func startRequest(api :API,nestedParams :String = "",params : [String:String] = [:],data : [String:Data] = [:],headers: HTTPHeaders = [:], completion:@escaping ([String:Any],Bool,String)->Void){
            print("full domain \(api.values.url + nestedParams)")
            AF.upload(multipartFormData: { (multipartFormData) in
                for (key, value) in params {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key )
                }
                
                
                for (key, value) in data {
                    multipartFormData.append(value, withName: key,fileName: "\(key).jpg", mimeType: "image/jpeg")
                }
                
            }, to: api.values.url + nestedParams , method:api.values.reqeustType ,headers: headers).uploadProgress {(progress) in
                print("file upload progress \(progress)%")
                
            }.responseJSON { (response) in
                
                if API.DEBUG {
                    if let statusCode = response.response?.statusCode {
                        print(API.TAG + "status code : \(statusCode)" )
                    }
                }
                
                switch(response.result)
                {
                case .success(let value):
                    if let resp = value as? [String:Any] {
                        completion(resp,true,"")
                    }else {
                        completion([:],false,"no data was found in response")
                    }
                    if API.DEBUG {
                        debugPrint(value)
                    }
                case .failure(let error) :
                    if API.DEBUG {
                        print(response.error.debugDescription)
                        print(error.errorDescription)
                        
                    }
                    completion([:],false,error.localizedDescription)
                }
                
                
            }
        }
        
        
        
    }
