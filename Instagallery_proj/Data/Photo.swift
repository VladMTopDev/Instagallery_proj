//
//  Photo.swift
//


import UIKit
import ObjectMapper

struct PhotoInfo: Mappable {
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    var url: String?
    var width: Int?
    var height: Int?
    
    // Mapping json to Photo object
    mutating func mapping(map: Map) {
        url    <- map["url"]
        width  <- map["width"]
        height <- map["height"]
    }
}

struct Photo: Mappable {
    
    var id: String?
    var createdTime: String?
    var thumbnailPhotos: PhotoInfo?
    var standardResolutionPhotos: PhotoInfo?
    var lowResolutionPhotos:PhotoInfo?

    init?(map: Map) {
        mapping(map: map)
    }
    
    // Mapping json to Photo object
    mutating func mapping(map: Map) {
        id <- map["id"]
        createdTime <- map["created_time"]
        thumbnailPhotos <- (map["images"], transformToPhotoInfo(type:"thumbnail"))
        standardResolutionPhotos <- (map["images"], transformToPhotoInfo(type:"standard_resolution"))
        lowResolutionPhotos <- (map["images"], transformToPhotoInfo(type: "low_resolution"))
    }

    // MARK: Helpers
    // Transforms json to PhotoInfo object
    private func transformToPhotoInfo(type: String) -> TransformOf<PhotoInfo, Dictionary<String,Any>> {
        let transformThumbnailPhotos = TransformOf<PhotoInfo, Dictionary<String,Any>>(fromJSON: { (value) -> PhotoInfo? in
            if let dict = value, let photoInfo = dict[type] as? [String:Any] {
                let map = Map.init(mappingType: .fromJSON, JSON: photoInfo)
                return PhotoInfo.init(map: map)
            }
            return nil
        }) { (photoInfo) -> Dictionary<String, Any>? in
            if let info = photoInfo {
                return info.toJSON()
            }
            return nil
        }
        return transformThumbnailPhotos
    }
    
}
