//
//  OAuthViewController.swift
//  Epintra
//
//  Created by Maxime Junger on 06/03/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import UIKit
import WebKit

class OAuthViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    var webView: WKWebView!

    /// EPITECH intranet path
    let epitechPath = "https://intra.epitech.eu/"

    /// Path of the Office365 application where we should redirect the user
    let office365 = "https://login.microsoftonline.com/common/oauth2/authorize?response_type=code&client_id=e05d4149-1624-4627-a5ba-7472a39e43ab&redirect_uri=https%3A%2F%2Fintra.epitech.eu%2Fauth%2Foffice365&state=%2F"

    /// Boolean to know if we are coming from the Intranet
    var movedFromEpitechIntranet = false

    /// User token
    var epitechToken: String?

    /// User email
    var userEmail: String?

    /// Regular expression to extract the token value from the cookies
    let tokenRegexp = "(?<=user=)[^;]*"

    /// Delegate to call when the authentication is finished
    weak var oAuthDelegate: OAuthDelegate?

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.view = self.webView

        self.title = NSLocalizedString("officeAuth", comment: "")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = self.webView.load(urlString: self.epitechPath)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {

        /// Try to extract the token of the user
        if let response = navigationResponse.response as? HTTPURLResponse, let fields = response.allHeaderFields as? [String: String] {
            if let token = getToken(fromHeaders: fields) {
                self.epitechToken = token
            }

        }

        // Try to get the email of the user in URL
        if self.userEmail == nil, let email = getQueryStringParameter(url: webView.url?.absoluteString, param: "username") {
            self.userEmail = email
        }

        // Check if we are on the EPITECH intranet.
        // If it is the first time we are here, we go to the Office365 auth.
        // Otherwise, we call the delegate and close our view.
        if webView.url?.absoluteString == epitechPath {
            if movedFromEpitechIntranet == false && self.epitechToken != nil {
                let url = URL.init(string: office365)
                let request = URLRequest(url: url!)
                webView.load(request)
                decisionHandler(.cancel)
                movedFromEpitechIntranet = true
                return
            } else {
                self.dismiss(animated: true, completion: {
                    self.oAuthDelegate?.authentified(withEmail: self.userEmail, andToken: self.epitechToken)
                })
            }
        }
        decisionHandler(.allow)
    }

    /// Extract given query value from the provided url
    ///
    /// - Parameters:
    ///   - url: URL maybe containing the query
    ///   - param: query
    /// - Returns: value
    func getQueryStringParameter(url: String?, param: String) -> String? {
        if let url = url, let urlComponents = URLComponents(string: url), let queryItems = (urlComponents.queryItems) {
            return queryItems.filter({ (item) in item.name == param }).first?.value!
        }
        return nil
    }

    /// Extract the token value from EPITECH header
    ///
    /// - Parameter headers: Request headers
    /// - Returns: token value
    func getToken(fromHeaders headers: [String: String]) -> String? {
        if let cookiesSet = headers["Set-Cookie"], let range = cookiesSet.range(of:tokenRegexp, options: .regularExpression) {
            return cookiesSet.substring(with:range)
        }
        return nil
    }

    /// User cancelled the login
    ///
    /// - Parameter sender: button
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
