//
//  LoginViewController.swift
//


import UIKit
import WebKit
import PKHUD
import Rswift

class LoginViewController: UIViewController {

    var loginWebView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        let configuration = WKWebViewConfiguration()
        loginWebView = WKWebView.init(frame: .zero, configuration: configuration)
        loginWebView?.navigationDelegate = self
        if let apiAuthURl = InstagramApiProvider.shared.getAuthUrl(), let webView = loginWebView {
            view.addSubview(webView)
            setupConstraintsForWebView()
            let urlRequest = URLRequest(url: apiAuthURl)
            loadRequest(webView: webView, urlRequest: urlRequest)
        }
    }
    
    // Loads auth request using webview with reachability checking
    func loadRequest(webView: WKWebView, urlRequest: URLRequest) {
        HUD.show(.systemActivity)
        if NetworkManager.isReachable() {
            webView.load(urlRequest)
        } else {
            HUD.hide()
            showOkAlert(withTitle: R.string.localizable.error(), message: R.string.localizable.noConnectionMessage()) { [weak self] (success) in
                self?.loadRequest(webView: webView, urlRequest: urlRequest)
            }
        }
    }
    
    // Setups constrains for webview
    private func setupConstraintsForWebView() {
        if let webView = loginWebView {
            webView.translatesAutoresizingMaskIntoConstraints = false
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
            let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
            webView.topAnchor.constraint(equalTo: view.topAnchor, constant: statusBarHeight).isActive = true
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
       }
    }
    
    // Opens gallery screen
    private func openGalleryScreen() {
        navigationController?.pushViewController(GalleryViewController(), animated: true)
    }
    
}

extension LoginViewController: WKNavigationDelegate {
    
    // MARK: WKNavigationDelegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
   
        InstagramApiProvider.shared.handleAccessToken(urlRequest: navigationAction.request) { [weak self] (success, error) in
            if success {
                decisionHandler(.cancel)
                self?.openGalleryScreen()
            } else {
                decisionHandler(.allow)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        HUD.hide()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        HUD.hide()
    }
    
}

