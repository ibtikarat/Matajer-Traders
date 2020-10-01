//
//  reportsVC.swift
//  Matajer Traders
//
//  Created by Heba lubbad on 9/23/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//


import UIKit
import WebKit
import Alamofire



class ReportsVC: UIViewController , WKNavigationDelegate {
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var webView: WKWebView!
    var isMain:Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.alwaysBounceHorizontal = false
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: UIControl.Event.valueChanged)
        webView.scrollView.addSubview(refreshControl)
        webView.scrollView.bounces = true
        webView.navigationDelegate = self
        self.loadPage()
        
        
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        if isMain {
            self.pop()
        }else {
            webView.goBack()
        }
    }
    
    func loadPage(){
        var urlRequest = URLRequest(url: URL(string:API.DOMAIN_URL + "report")!)
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
            routeNoInternet()
            return
        }
        
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
                    if currentURL.description != "\(API.DOMAIN_URL)report" {
                        isMain = false
                    }else {
                        isMain = true
                    }
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
