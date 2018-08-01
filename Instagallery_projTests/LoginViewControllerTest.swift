//
//  LoginViewControllerTest.swift
//


import Foundation
import XCTest
import WebKit
@testable import Instagallery_proj

class FakeNavigationAction: WKNavigationAction {
    
    let testRequest: URLRequest
    override var request: URLRequest {
        return testRequest
    }
    
    init(testRequest: URLRequest) {
        self.testRequest = testRequest
        super.init()
    }
}

class LoginViewControllerTest: XCTestCase {
    
    func test_viewDidLoad_webViewLoadRequest() {
        let loginVC = LoginViewController()
        let _ = loginVC.view       
        XCTAssertNotNil(loginVC.loginWebView?.url)
    }

    func test_wkWebViewNavigation_instagramRedirect() {
        let loginVC = LoginViewController()
        let _ = loginVC.view
        let webView = loginVC.loginWebView
        XCTAssertNotNil(webView)
        XCTAssertNotNil(loginVC.loginWebView?.navigationDelegate)
        var receivedPolicy: WKNavigationActionPolicy?
        let url = URL(string: InstagramApiProviderConstants.RedirectLink+"/"+InstagramApiProviderConstants.accessTokenLinkField)
        let urlRequest = URLRequest(url: url!)
        let fakeNavigationAction = FakeNavigationAction(testRequest: urlRequest)
        let expectation = self.expectation(description: "redirectExpectation")
        webView?.navigationDelegate?.webView!(webView!, decidePolicyFor: fakeNavigationAction, decisionHandler: { receivedPolicy = $0 })
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            expectation.fulfill()
            XCTAssertEqual(receivedPolicy, .cancel) // navgiation should be canceled
        }
        waitForExpectations(timeout: 6, handler: nil)
    }
    
    func test_wkWebViewNavigation_notInstagramRedirect() {
        let loginVC = LoginViewController()
        let _ = loginVC.view
        let webView = loginVC.loginWebView
        XCTAssertNotNil(webView)
        XCTAssertNotNil(loginVC.loginWebView?.navigationDelegate)
        var receivedPolicy: WKNavigationActionPolicy?
        let url = URL(string: "https://")
        let urlRequest = URLRequest(url: url!)
        let fakeNavigationAction = FakeNavigationAction(testRequest: urlRequest)
        let expectation = self.expectation(description: "redirectExpectation")
        webView?.navigationDelegate?.webView!(webView!, decidePolicyFor: fakeNavigationAction, decisionHandler: { receivedPolicy = $0 })
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            expectation.fulfill()
            XCTAssertEqual(receivedPolicy, .allow) // navgiation should be allowed
        }
        waitForExpectations(timeout: 6, handler: nil)
    }
}
