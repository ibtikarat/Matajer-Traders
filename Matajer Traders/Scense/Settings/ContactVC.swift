//
//  contactVC.swift
//  Matajer Traders
//
//  Created by Heba lubbad on 9/23/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SVProgressHUD

class ContactVC: UIViewController , WKNavigationDelegate {
    
    @IBOutlet var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: UIControl.Event.valueChanged)
        webView.scrollView.addSubview(refreshControl)
        webView.scrollView.bounces = true
        webView.navigationDelegate = self
        
        var urlRequest = URLRequest(url: URL(string:API.DOMAIN_URL + "client")!)
        urlRequest.httpMethod = "GET"
        var header:[String:String] = [:]
        header["Accept"] = "application/json"
        header["Accept-Language"] = AppDelegate.shared.language
        
        if let authToken = MatajerUtility.loadUser()?.apiToken {
            header["Authorization"] = "Bearer \(authToken)"
        }
        let httpHeader = HTTPHeaders(header)
        urlRequest.headers = httpHeader
        self.webView.load(urlRequest);
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil);
        
    }
 
    @IBAction func backAction(_ sender: Any) {
        self.pop()
    }
    
    
    
    @objc
    func refreshWebView(_ sender: UIRefreshControl) {
        webView?.reload()
        sender.endRefreshing()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "estimatedProgress" {
            if self.webView.estimatedProgress != 1 {
                SVProgressHUD.show()
                
            }else {
                SVProgressHUD.dismiss()
                
                if let currentURL = self.webView.url?.absoluteString{
                    print(currentURL)
                    if currentURL.contains("storeLogin"){
                        self.webView.load(NSURLRequest(url: URL(string: "https://mapp.sa/login")!) as URLRequest);
                        
                    }
                }
            }
            
            
            
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
          print("Error loading \(error)")
      }
}
