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
import QuickLook

class ProductsVC: UIViewController , WKNavigationDelegate , QLPreviewControllerDataSource {
    @IBOutlet var printBtn: UIButton!
    @IBOutlet var noti_count_lbl: AnimatableLabel!
    @IBOutlet var webView: WKWebView!
    @IBOutlet var userImgV: UIImageView!
    @IBOutlet var mainHeaderView: AnimatableView!
    @IBOutlet var subHeaderView: AnimatableView!
    @IBOutlet var titleLbl: UILabel!
    
    var documentPreviewController = QLPreviewController()
    var documentUrl = URL(fileURLWithPath: "")
    var webViewCookieStore: WKHTTPCookieStore!
    let webViewConfiguration = WKWebViewConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WebCacheCleaner.clean()
        webViewConfiguration.websiteDataStore = WKWebsiteDataStore.default()
        documentPreviewController.dataSource  = self
        webViewCookieStore = webView.configuration.websiteDataStore.httpCookieStore
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
       // self.routeSettings()
    }
    
    
    
    @objc
    func refreshWebView(_ sender: UIRefreshControl) {
        webView.reload()
        sender.endRefreshing()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "estimatedProgress" {
            self.printBtn.isHidden = true
            if self.webView.estimatedProgress != 1 {
                self.showIndicator()
                
            }else {
                self.hideIndicator()
                if let currentURL = self.webView.url?.absoluteString{
                    
                    webView.evaluateJavaScript("document.getElementsByName('printIt')[0].getAttribute('content')") { [self] (result, error) -> Void in
                        if error != nil {
                            print(error?.localizedDescription)
                            
                        }else {
                            print(result.debugDescription)
                            let link = "\( result!)"
                            print("\(link)")
                            self.documentUrl =  URL(string: link)!
                            print(" documentUrl  \(self.documentUrl)")
                            if   ( self.documentUrl.description.contains("/pdf/") ){
                                self.printBtn.isHidden = false
                            }
                        }
                    }
                    if currentURL.description != "\(API.DOMAIN_URL)product" {
                        
                        mainHeaderView.isHidden = true
                        subHeaderView.isHidden = false
                         titleLbl.text =  webView.title
                    }else {
                        mainHeaderView.isHidden = false
                        subHeaderView.isHidden = true
                       
                    }
                    print(currentURL)
                    if currentURL.contains("storeLogin"){
                        loadPage()
                        
                    }
                }
            }
            
            
            
        }
    }

    

     func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping ((WKNavigationActionPolicy) -> Void)) {

        if let currentURL = navigationAction.request.url?.absoluteString{
                print(currentURL)
            if (currentURL.contains("/product/") && currentURL.contains("view")) {
                if let url = URL(string: "\(currentURL)"),
                           UIApplication.shared.canOpenURL(url)
                       {
                           if #available(iOS 10.0, *) {
                               UIApplication.shared.open(url, options: [:], completionHandler: nil)
                           } else {
                               UIApplication.shared.openURL(url)
                           }
                       }
            }
        }

        decisionHandler(.allow)
    }
    
    @IBAction func printAction(_ sender: Any) {
        
        loadAndDisplayDocumentFrom(url: self.documentUrl)
    }
    
    /*
     Download the file from the given url and store it locally in the app's temp folder.
     The stored file is then opened using QuickLook preview.
     */
    private func loadAndDisplayDocumentFrom(url downloadUrl : URL) {
        let localFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(downloadUrl.lastPathComponent)
        
        self.showIndicator()
        
        // getAllCookies needs to be called in main thread??? (https://medium.com/appssemble/wkwebview-and-wkcookiestore-in-ios-11-5b423e0829f8)
        //??? needed?? DispatchQueue.main.async {
        self.webViewCookieStore.getAllCookies { (cookies) in
            for cookie in cookies {
                if cookie.domain.range(of: "my.domain.xyz") != nil {
                    HTTPCookieStorage.shared.setCookie(cookie)
                    debugPrint("Sync cookie [\(cookie.domain)] \(cookie.name)=\(cookie.value)")
                } else {
                    debugPrint("Skip cookie [\(cookie.domain)] \(cookie.name)=\(cookie.value)")
                }
            }
            debugPrint("FINISHED COOKIE SYNC")
            
            debugPrint("Downloading document from url=\(downloadUrl.absoluteString)")
            URLSession.shared.dataTask(with: downloadUrl) { data, response, err in
                guard let data = data, err == nil else {
                    debugPrint("Error while downloading document from url=\(downloadUrl.absoluteString): \(err.debugDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    debugPrint("Download http status=\(httpResponse.statusCode)")
                }
                
                // write the downloaded data to a temporary folder
                do {
                    try data.write(to: localFileURL, options: .atomic)   // atomic option overwrites it if needed
                    debugPrint("Stored document from url=\(downloadUrl.absoluteString) in folder=\(localFileURL.absoluteString)")
                    self.hideIndicator()
                    DispatchQueue.main.async {
                        self.documentUrl = localFileURL
                        self.documentPreviewController.refreshCurrentPreviewItem()
                        self.present(self.documentPreviewController, animated: true, completion: nil)
                    }
                } catch {
                    self.hideIndicator()
                    debugPrint(error)
                    return
                }
            }.resume()
        }
    }
    
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return documentUrl as QLPreviewItem
    }
    
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    
}
