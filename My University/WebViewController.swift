//
//  WebViewController.swift
//  My University
//
//  Created by Yura Voevodin on 4/3/19.
//  Copyright © 2019 Yura Voevodin. All rights reserved.
//

import WebKit
import UIKit

class WebViewController: UIViewController {

  // MARK: - Properties

  var urlString = ""
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

    navigationController?.navigationBar.prefersLargeTitles = false

    let myURL = URL(string: urlString)
    let myRequest = URLRequest(url: myURL!)
    webView.load(myRequest)
  }
}

// MARK: - WKUIDelegate

extension WebViewController: WKUIDelegate {

}
