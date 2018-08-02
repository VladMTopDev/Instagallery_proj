//
//  IntagramApi.swift
//

import Moya

enum InstagramApi {
    case getPhotos()
}

extension InstagramApi: TargetType {
    
    var baseURL: URL { return URL(string: InstagramApiProviderConstants.BaseUrl)! }

    var path: String {
        switch self {
            case .getPhotos():
                return InstagramApiProviderConstants.Photos
        }
    }
    
    var method: Method {
        switch self {
        case .getPhotos:
            return .get
        }
    }
    
    var sampleData: Data {
        switch self {
        case .getPhotos:
            return "test".data(using: .utf8)!
        }
    }
    
    var task: Task {
        switch self {
        case .getPhotos:
            return .requestParameters(parameters: ["access_token": InstagramApiProvider().accessToken ?? ""], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
}


