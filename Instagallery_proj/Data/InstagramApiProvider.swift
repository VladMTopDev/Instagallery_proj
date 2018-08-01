//
//  InstagramApiProvider.swift
//


import UIKit
import Keychain
import Moya
import Result
import ObjectMapper
import WebKit


typealias RequestCompletion = (_ success: Bool, _ error: Error?) -> Void

struct InstagramApiProviderConstants {
    
    static let BaseUrl = "https://api.instagram.com/"
    
    static let Auth = "oauth/authorize/"
    static let Photos = "v1/users/self/media/recent"
    
    static let ClientId = "some_client_id_here" // You can get it on https://www.instagram.com/developer/clients/manage/
    static let ClientSecret = "some_client_secret_here" // You can get it on https://www.instagram.com/developer/clients/manage/
    static let RedirectLink = "https://exampleredirect" // You can get it on https://www.instagram.com/developer/clients/manage/
    static let Scope = "basic+public_content" // Access permissions keys
    static let accessTokenKey = "accessTokenKey"
    static let accessTokenLinkField = "#access_token="
}

protocol InstagramApiProviderDelegate: class {
    
    func didFetchedUserPhotos(_ provider: InstagramApiProvider, userPhotos photos: [Photo], requestError error: Error?)
    func didLogout()
}

class InstagramApiProvider: NSObject {
    
    static let shared = InstagramApiProvider()
    
    var delegate: InstagramApiProviderDelegate?
    
    override init() {
        super.init()
    }
    
    private(set) var accessToken = Keychain.load(InstagramApiProviderConstants.accessTokenKey) {
         willSet(newValue) {
           let _ = Keychain.save(newValue ?? "", forKey: InstagramApiProviderConstants.accessTokenKey)
        }
    }

    func getAuthUrl() -> URL? {
        var authUrl: URL?
        let authParams = "%@%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@&DEBUG=True"
        let authString = String(format: authParams, InstagramApiProviderConstants.BaseUrl, InstagramApiProviderConstants.Auth, InstagramApiProviderConstants.ClientId, InstagramApiProviderConstants.RedirectLink, InstagramApiProviderConstants.Scope)
        if let url = URL(string:authString) {
            authUrl = url
        }
        return authUrl
    }

    func logout() {
        let dateStore = WKWebsiteDataStore.default()
        dateStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (dataRecords) in
            for record in dataRecords {
                if record.displayName.contains("instagram") {
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: { [weak self] in
                        self?.delegate?.didLogout()
                    })
                }
            }
        }
        let _ = Keychain.delete(InstagramApiProviderConstants.accessTokenKey)
    }
    
    func handleAccessToken(urlRequest: URLRequest, completion: @escaping RequestCompletion) {
        var success = false
        if let requestURLString = (urlRequest.url?.absoluteString), requestURLString.hasPrefix(InstagramApiProviderConstants.RedirectLink) {
            if let tokenRange = requestURLString.range(of: InstagramApiProviderConstants.accessTokenLinkField) {
                let token = String(requestURLString[tokenRange.upperBound...])
                accessToken = token
                success = true
            }
        }
       completion(success, nil)
    }
    
    // Request to fecth users photos
    func getUserPhotos() {
        MoyaProvider<InstagramApi>().request(.getPhotos()) { [weak self] result in
            self?.parseUserPhotosResult(result)
        }
    }
    
    
    // Parse users photos from moya requested result
    private func parseUserPhotosResult(_ result: Result<Moya.Response, MoyaError>) {
        var parseError: Error?
        var photos = [Photo]()
        switch result {
        case let .success(response):
            do {
                photos = try parsePhotosResponse(response)
            }
            catch {
                parseError = error
            }
        case let .failure(requestError):
            parseError = requestError
        }
        delegate?.didFetchedUserPhotos(self, userPhotos: photos, requestError: parseError)
    }
    
    // Parse users photos from json response
    func parsePhotosResponse(_ response: Response) throws -> [Photo] {
        var photos = [Photo]()
        if let photosJSON = try response.mapJSON() as? [String: Any], let data = photosJSON["data"] as? [Any] {
            data.forEach { (images) in
                if let photoDictionary = images as? [String:Any] {
                    if let carousel = photoDictionary["carousel_media"] as? [[String:Any]] {
                        carousel.forEach({ (photo) in
                            var tempPhoto = photo
                            tempPhoto["id"] = photoDictionary["id"] ?? ""
                            tempPhoto["created_time"] = photoDictionary["created_time"] ?? ""
                            let map = Map(mappingType: .fromJSON, JSON: tempPhoto)
                            if let photo = Photo(map: map) {
                                photos.append(photo)
                            }
                        })
                    } else {
                        let map = Map(mappingType: .fromJSON, JSON: photoDictionary)
                        if let photo = Photo(map: map) {
                            photos.append(photo)
                        }
                    }
                    
                }
            }
            
        }
        return photos.filter({ (photo) -> Bool in
            var isFiltered = true
            if photo.thumbnailPhotos == nil && photo.lowResolutionPhotos == nil && photo.standardResolutionPhotos == nil {
                isFiltered = false
            }
            return isFiltered
        })
    }
    
}

