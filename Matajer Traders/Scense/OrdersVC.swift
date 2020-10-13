//
//  OrdersVC.swift
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


class OrdersVC: UIViewController , WKNavigationDelegate , QLPreviewControllerDataSource {
    
    
    
    @IBOutlet var printBtn: UIButton!
    @IBOutlet var noti_count_lbl: AnimatableLabel!
    @IBOutlet var webView: WKWebView!
    @IBOutlet var userImgV: UIImageView!
    @IBOutlet var mainHeaderView: AnimatableView!
    @IBOutlet var subHeaderView: AnimatableView!
    @IBOutlet var titleLbl: UILabel!
    
    
    var current_url:URL =  URL(string:API.DOMAIN_URL + "order")!
    
    var documentPreviewController = QLPreviewController()
       var documentUrl = URL(fileURLWithPath: "")
       
       
       var webViewCookieStore: WKHTTPCookieStore!
       let webViewConfiguration = WKWebViewConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
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
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UpdateOrders"), object: nil, queue: nil) { (notification) in
            self.loadPage()
            
        }
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        debugPrint("did receive message \(message.name)")


        if (message.name == "openDocument") {
            previewDocument(messageBody: message.body as! String)
        } else if (message.name == "jsError") {
            debugPrint(message.body as! String)
        }
    }
    
    private func previewDocument(messageBody: String) {
          // messageBody is in the format ;data:;base64,
          
          // split on the first ";", to reveal the filename
          let filenameSplits = messageBody.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: false)
          
          let filename = String(filenameSplits[0])
          
          // split the remaining part on the first ",", to reveal the base64 data
          let dataSplits = filenameSplits[1].split(separator: ",", maxSplits: 1, omittingEmptySubsequences: false)
          
          let data = Data(base64Encoded: String(dataSplits[1]))
          
          if (data == nil) {
              debugPrint("Could not construct data from base64")
              return
          }
          
          // store the file on disk (.removingPercentEncoding removes possible URL encoded characters like "%20" for blank)
          let localFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename.removingPercentEncoding ?? filename)
          
          do {
              try data!.write(to: localFileURL);
          } catch {
              debugPrint(error)
              return
          }
          
          // and display it in QL
          DispatchQueue.main.async {
              self.documentUrl = localFileURL
              self.documentPreviewController.refreshCurrentPreviewItem()
              self.present(self.documentPreviewController, animated: true, completion: nil)
          }
      }
    
    func loadPage(){
        
        var urlRequest = URLRequest(url: URL(string:API.DOMAIN_URL + "order")!)
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
                    self.current_url = self.webView.url!
                    webView.evaluateJavaScript("document.getElementsByName('printInvoice')[0].getAttribute('content')") { [self] (result, error) -> Void in
                        if error != nil {
                            print(error?.localizedDescription)
                        }else {
                            print(result.debugDescription)
                  let link = "\( result!)"
                            print("\(link)")
                            self.documentUrl =  URL(string: link)!
                            print(" documentUrl  \(self.documentUrl)")
                        }
                    }
                    
                    if currentURL.description != "\(API.DOMAIN_URL)order" {
                        
                        mainHeaderView.isHidden = true
                        subHeaderView.isHidden = false
                        titleLbl.text =  webView.title
                        if   (currentURL.contains("show") ){
                            self.printBtn.isHidden = false
                        }else {
                            self.printBtn.isHidden = true
                        }
                    }else {
                        mainHeaderView.isHidden = false
                        subHeaderView.isHidden = true
                        
                        
                    }
                    print(currentURL)
                    if currentURL.contains("storeLogin"){
                        loadPage()
                        
                    }                }
            }
            
           
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let currentURL = self.webView.url?.absoluteString{
            print(currentURL)
           
          
            if currentURL.contains("login"){
                //  self.tabBarController?.tabBar.isHidden = true
            }else {
                
                // self.tabBarController?.tabBar.isHidden = false
            }
        }
        
    }
    

    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Error loading \(error)")
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
