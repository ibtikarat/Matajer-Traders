//
//  orderDetailsVC.swift
//  Matajer Traders
//
//  Created by Heba lubbad on 9/29/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//


import UIKit
import WebKit
import Alamofire


class orderDetailsVC: UIViewController , WKNavigationDelegate {
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var webView: WKWebView!
    var orderId:Int?
    var orderNo:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WebCacheCleaner.clean()
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.alwaysBounceHorizontal = false
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: UIControl.Event.valueChanged)
        webView.scrollView.addSubview(refreshControl)
        webView.scrollView.bounces = true
        webView.navigationDelegate = self
        if orderNo?.count ?? 0 > 0 {
            titleLbl.text  = "طلب رقم \(orderNo ?? "")"
        }else{
            titleLbl.text  = "تفاصيل الطلب"
        }
    loadPage()
    }
    
    func loadPage(){
        print("orderid \(orderId ?? 0)")
         var urlRequest = URLRequest(url: URL(string:API.DOMAIN_URL + "order/\(orderId ?? 0)")!)
        print(urlRequest.url?.absoluteString ?? "")
         urlRequest.httpMethod = "GET"
         var header:[String:String] = [:]
         header["Accept"] = "application/json"
         header["Accept-Language"] = AppDelegate.shared.language
         
         if let authToken = MatajerUtility.loadUser()?.apiToken {
             header["Authorization"] = "Bearer \(authToken)"
         }
         let httpHeader = HTTPHeaders(header)
         urlRequest.headers = httpHeader
         if isConnectedToNetwork() {
             self.webView.load(urlRequest);
             self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
         } else {
             self.routeNoInternet()
         }
     }
     
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    
    
    
    
    @objc
    func refreshWebView(_ sender: UIRefreshControl) {
      webView.reload()
        sender.endRefreshing()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "estimatedProgress" {
            if self.webView.estimatedProgress != 1 {
                self.showIndicator()
                
            }else {
                self.hideIndicator()
                    titleLbl.text =  webView.title
                if let currentURL = self.webView.url?.absoluteString{
                    print(currentURL)
                    print("orderid \(orderId ?? 0)")
                    if currentURL.contains("storeLogin"){
                                          loadPage()
                                           
                                       }
                }
            }
            
            
            
        }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let currentURL = self.webView.url?.absoluteString{
            print(currentURL)
            if currentURL.contains("login"){
                //  self.tabBarController?.tabBar.isHidden = true
            }else {
                
                //    self.tabBarController?.tabBar.isHidden = false
            }
        }
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
          print("Error loading \(error)")
      }
}
