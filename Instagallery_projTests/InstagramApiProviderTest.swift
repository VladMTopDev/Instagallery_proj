//
//  InstagramApiProviderTest.swift
//


import Foundation
import XCTest
import Moya
import Result

@testable import Instagallery_proj

class InstagramApiProviderTest: XCTestCase {
    
    func test_getAuthUrl() {
        let apiManager = InstagramApiProvider.shared
        let authUrl = apiManager.getAuthUrl()
        XCTAssertNotNil(authUrl)
    }
    
    func test_success_handleAccessToken() {
        let apiManager = InstagramApiProvider.shared
        let tokenRedirectLink = String(format: "%@/%@testvalue", InstagramApiProviderConstants.RedirectLink, InstagramApiProviderConstants.accessTokenLinkField)
        let url = URL(string:tokenRedirectLink)
        let urlRequest = URLRequest(url:url!)
        let expectation = self.expectation(description: "handleAccessToken")
        apiManager.handleAccessToken(urlRequest: urlRequest) { (success, error) in
            expectation.fulfill()
            XCTAssertNil(error)
            XCTAssertTrue(success)
            XCTAssertNotNil(apiManager.accessToken)
        }
        
        waitForExpectations(timeout: 8, handler: nil)
    }
    
    func test_failure_handleAccessToken() {
        let apiManager = InstagramApiProvider.shared
        let authUrl = URL(string:"https://")
        let urlRequest = URLRequest(url:authUrl!)
        let expectation = self.expectation(description: "handleAccessToken")
        apiManager.handleAccessToken(urlRequest: urlRequest) { (success, error) in
            expectation.fulfill()
            XCTAssertFalse(success)
        }
        waitForExpectations(timeout: 8, handler: nil)
    }
    
    func test_parsePhotosResponse() {
        let apiManager = InstagramApiProvider.shared
        do {
            let exampleData = try JSONSerialization.data(withJSONObject: ["data":[["created_time":"123", "images":["thumbnail": ["width":200, "height":200, "url":"https://testlink.com"], "standard_resolution":["width":200, "height":200, "url":"https://testlink.com"], "low_resolution":["width":200, "height":200, "url":"https://testlink.com"]]], ["created_time":"123", "images":["thumbnail": ["width":200, "height":200, "url":"https://testlink.com"], "standard_resolution":["width":200, "height":200, "url":"https://testlink.com"], "low_resolution":["width":200, "height":200, "url":"https://testlink.com"]]]]], options: []) // 2 values
            let response = Response.init(statusCode: 200, data: exampleData)
            let photos = try apiManager.parsePhotosResponse(response)
            XCTAssertNotNil(photos)
            XCTAssertTrue(photos.count == 2) // Should be unparsed 2 photo objects
        } catch {
            XCTAssertNil(error)
        }
    }
    
    func test_parsePhotosFilteredResponse() {
        let apiManager = InstagramApiProvider.shared
        do {
            let exampleData = try JSONSerialization.data(withJSONObject: ["data":[["created_time":"123", "images":[]], ["created_time":"123", "images":["thumbnail":["url":"testurl", "width": 123, "height":123]]]]], options: []) // 2 values
            let response = Response.init(statusCode: 200, data: exampleData)
            let photos = try apiManager.parsePhotosResponse(response)
            XCTAssertNotNil(photos)
            XCTAssertTrue(photos.count == 1) // Should be 1 photo object
        } catch {
            XCTAssertNil(error)
        }
        
    }
    
    func test_parsePhotosResponseCarousel() {
        let apiManager = InstagramApiProvider.shared
        do {
            let exampleData = try JSONSerialization.data(withJSONObject: ["data":[["created_time":"123", "images":[], "carousel_media":[["images":["thumbnail":["url":"123", "width":200,"height":200], "low_resolution":["url":"123", "width":200,"height":200], "standart_resolution":["url":"123", "width":200,"height":200]]], ["images":["thumbnail":["url":"123", "width":200,"height":200], "low_resolution":["url":"123", "width":200,"height":200], "standart_resolution":["url":"123", "width":200,"height":200]]]]], ["created_time":"123", "images":["thumbnail":["url":"testurl", "width": 123, "height":123]]]]], options: []) // 2 values from carousel_media and 1 from data object
            let response = Response.init(statusCode: 200, data: exampleData)
            let photos = try apiManager.parsePhotosResponse(response)
            XCTAssertNotNil(photos)
            XCTAssertTrue(photos.count == 3) // Should be 3 photo object
        } catch {
            XCTAssertNil(error)
        }
    }
    
    
    
    func test_logout() {
        let apiManager = InstagramApiProvider.shared
        apiManager.logout()
        var isContains = false
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                if cookie.domain.contains(".instagram.com") {
                    isContains = true
                }
            }
        }
        XCTAssertFalse(isContains)
        XCTAssertNil(apiManager.accessToken)
    }
    
}
