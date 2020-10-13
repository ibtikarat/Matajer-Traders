//
//  SuperNotificationVC.swift
//  Matajer Traders
//
//  Created by Heba lubbad on 10/6/20.
//  Copyright © 2020 Ibtikarat. All rights reserved.
//

import UIKit
import WebKit


class SuperNotificationVC: UIViewController, WKNavigationDelegate, UIScrollViewDelegate {
    
    @IBOutlet var webView: WKWebView!
    @IBOutlet var webViewHieghtConstraint: NSLayoutConstraint!
    var htmlContent:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.isOpaque = false
        webView.navigationDelegate = self
        webView.frame.size = webView.scrollView.contentSize
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.alwaysBounceHorizontal = false
        let dir = "rtl"
        let htmlContents =  """
        <meta name='viewport' content='width=device-width-60, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'>
        <link rel=\"stylesheet\" type=\"text/css\" href=\"iPhone.css\">
        </header><body dir = '\(dir)'>\(htmlContent ?? "")</body>
        """
        webView.loadHTMLString(htmlContents, baseURL: URL(fileURLWithPath:  Bundle.main.path(forResource: "iPhone", ofType: "css")!))
        webView.scrollView.bounces = true
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss()
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        self.webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                self.webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                    self.webViewHieghtConstraint.constant = (height as! CGFloat)
                })
            }
            
        })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var action: WKNavigationActionPolicy?
        
        defer {
            decisionHandler(action ?? .allow)
        }
        
        guard let url = navigationAction.request.url else { return }
        
        if navigationAction.navigationType == .linkActivated {
            action = .cancel  // Stop in WebView
            UIApplication.shared.open(url)
        }
        
    }
}
