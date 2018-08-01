//
//  NetworkManager.swift
//


import UIKit
import Alamofire

class NetworkManager: NSObject {

    // Checks network reachability state
    static func isReachable() -> Bool {
        var isReachable = false
        if let networkManager = NetworkReachabilityManager() {
           isReachable = networkManager.isReachable
        }
        return isReachable
    }
}
