//
//  ProductsVC.swift
//  Matajer Traders
//
//  Created by Heba lubbad on 9/15/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SDWebImage
import IBAnimatable


class ProductsVC: UIViewController , WKNavigationDelegate {
    
    @IBOutlet var noti_count_lbl: AnimatableLabel!
    @IBOutlet var webView: WKWebView!
    @IBOutlet var userImgV: UIImageView!
    @IBOutlet var mainHeaderView: AnimatableView!
    @IBOutlet var subHeaderView: AnimatableView!
    @IBOutlet var titleLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.alwaysBounceHorizontal = false
        userImgV.fetchingImage(url:  MatajerUtility.loadUser()?.storeData?.logo ?? "")
        if MatajerUtility.loadUser()?.notificationAlarm ?? 0 > 0 {
            if MatajerUtility.loadUser()?.notificationAlarm ?? 0 > 99 {
                noti_count_lbl.text = "99+"
            }else{
                noti_count_lbl.text = "\(MatajerUtility.loadUser()?.notificationAlarm ?? 0)"
            }
        }else{
            noti_count_lbl.isHidden = true
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: UIControl.Event.valueChanged)
        webView.scrollView.addSubview(refreshControl)
        webView.scrollView.bounces = true
        webView.navigationDelegate = self
        loadPage()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "updateUserInfo"), object: nil, queue: nil) { (notification) in
            self.updateUserData { (result) in
                if result {
                    self.userImgV.fetchingImage(url:  MatajerUtility.loadUser()?.storeData?.logo ?? "")
                }
            }
            
        }
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "updateNotificationNumber"), object: nil, queue: nil) { (notification) in
            if (notification.userInfo as? [String: Any]) != nil
            {
                
                let badge = notification.userInfo?["badge"] as? Int
                
                if badge == 0 {
                    self.noti_count_lbl.isHidden = true
                }else{
                    self.noti_count_lbl.isHidden = false
                    if badge ?? 0 > 99 {
                        self.noti_count_lbl.text = "99+"
                    }else{
                        self.noti_count_lbl.text = "\(badge ?? 0)"
                    }
                    return
                }
            }
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UpdateProducts"), object: nil, queue: nil) { (notification) in
            self.loadPage()
            
        }
    }
    
    func loadPage(){
        
        var urlRequest = URLRequest(url: URL(string:API.DOMAIN_URL + "product")!)
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
        webView.goBack()
    }
    
    @IBAction func goToNotificationsAction(_ sender: Any) {
        routeNoifications()
    }
    
    @IBAction func goToSettingsAction(_ sender: Any) {
        self.routeSettings()
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
                if let currentURL = self.webView.url?.absoluteString{
                    if currentURL.description != "\(API.DOMAIN_URL)product" {
                        
                        mainHeaderView.isHidden = true
                        subHeaderView.isHidden = false
                    }else {
                        mainHeaderView.isHidden = false
                        subHeaderView.isHidden = true
                        titleLbl.text =  webView.title
                    }
                    print(currentURL)
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
                // self.tabBarController?.tabBar.isHidden = true
            }else {
                
                // self.tabBarController?.tabBar.isHidden = false
            }
        }
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Error loading \(error)")
    }
}
