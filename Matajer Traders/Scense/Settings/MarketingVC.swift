//
//  marketingsVC.swift
//  Matajer Traders
//
//  Created by Heba lubbad on 9/23/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import QuickLook


class MarketingVC: UIViewController , WKNavigationDelegate , QLPreviewControllerDataSource {
    
    @IBOutlet var printBtn: UIButton!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var webView: WKWebView!
    var isMain = true
    
    
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
        
        var urlRequest = URLRequest(url: URL(string:API.DOMAIN_URL + "coupon")!)
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
                
                if let currentURL = self.webView.url?.absoluteString{
                    if currentURL.description != "\(API.DOMAIN_URL)coupon" {
                        isMain = false
                    }else {
                        isMain = true
                    }
                    print(currentURL)
                    if currentURL.contains("storeLogin"){
                        loadPage()
                        
                    }
                }
            }
            
            
            
        }
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
