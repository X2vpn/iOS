// SPDX-License-Identifier: MIT
// Copyright © 2018-2021 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit
import WebKit

class X2PrivacyPolicy: UIViewController {

    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        webView.backgroundColor = .clear

        if let url = URL(string: "http://194.233.71.193:1221/privacy_policy/") {//Bundle.main.url(forResource: "privacy_policy", withExtension: "html"){
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }


    @IBAction func backTapped() {
        DispatchQueue.main.async {
            self.dismiss(animated: false)
        }
    }

}
