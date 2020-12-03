//
//  privacyVC.swift
//  Matajer Traders
//
//  Created by Heba lubbad on 9/23/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//


import UIKit
import WebKit
import Alamofire


class PrivacyVC: UIViewController , WKNavigationDelegate {
    
    @IBOutlet var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: UIControl.Event.valueChanged)
        webView.scrollView.addSubview(refreshControl)
        webView.scrollView.bounces = true
        webView.navigationDelegate = self
        loadPage()
        
        
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    
    
    
    @objc
    func refreshWebView(_ sender: UIRefreshControl) {
         webView.reload()
        sender.endRefreshing()
    }
    func loadPage(){
        var urlRequest = URLRequest(url: URL(string:API.DOMAIN_URL + "privacy")!)
        urlRequest.httpMethod = "GET"
        
        self.webView.load(urlRequest);
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil);
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "estimatedProgress" {
            if self.webView.estimatedProgress != 1 {
                self.showIndicator()
                
            }else {
                self.hideIndicator()
                
                if let currentURL = self.webView.url?.absoluteString{
                    print(currentURL)
                  if currentURL.contains("storeLogin"){
                                          loadPage()
                                           
                                       }
                }
            }
            
            
            
        }
    }
 
    
    
}
