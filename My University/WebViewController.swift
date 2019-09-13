//
//  WebViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/3/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import WebKit
import UIKit

struct WebPage {
  let url: String
  let title: String
}

class WebViewController: UIViewController {
    
    // MARK: - Properties

    var webPage: WebPage?
    var webView: WKWebView!
    
    // MARK: - Lifecycle
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let page = webPage else { return }
        
        let myURL = URL(string: page.url)
        let myRequest = URLRequest(url: myURL!)
        title = page.title
        webView.load(myRequest)
    }
}

// MARK: - WKUIDelegate

extension WebViewController: WKUIDelegate {
    
}
