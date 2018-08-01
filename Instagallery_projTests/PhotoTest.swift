//
//  PhotoTest.swift
//


import Foundation
import XCTest
import ObjectMapper
@testable import Instagallery_proj

class PhotoTest: XCTestCase {
    
    func test_photoMappingWithoutImages() {
        let testPhotoJSON = ["created_time":"123456789","id":"123456789"]
        let photoMap = Map.init(mappingType: .fromJSON, JSON: testPhotoJSON)
        let photo = Photo.init(map: photoMap)
        XCTAssertNotNil(photo)
        XCTAssertNotNil(photo?.createdTime)
        XCTAssertNotNil(photo?.id)
        XCTAssertNil(photo?.thumbnailPhotos)
        XCTAssertNil(photo?.lowResolutionPhotos)
        XCTAssertNil(photo?.standardResolutionPhotos)
    }
    
    func test_photoMappingWithImages() {
        let testPhotoJSON = ["created_time":"123456789","id":"123456789", "images":["thumbnail":["url":"link", "width":510, "height":510], "low_resolution":["url":"link", "width":510, "height":510], "standard_resolution":["url":"link", "width":510, "height":510]]] as [String : Any]
        let photoMap = Map.init(mappingType: .fromJSON, JSON: testPhotoJSON)
        let photo = Photo.init(map: photoMap)
        XCTAssertNotNil(photo)
        XCTAssertNotNil(photo?.id)
        XCTAssertNotNil(photo?.createdTime)
        XCTAssertNotNil(photo?.thumbnailPhotos)
        XCTAssertNotNil(photo?.lowResolutionPhotos)
        XCTAssertNotNil(photo?.standardResolutionPhotos)
    }
    
    func test_photoMappingWithBadJSON() {
        let testPhotoJSON = ["error":"404"]
        let photoMap = Map.init(mappingType: .fromJSON, JSON: testPhotoJSON)
        let photo = Photo.init(map: photoMap)
        XCTAssertNotNil(photo)
        XCTAssertNil(photo?.id)
        XCTAssertNil(photo?.createdTime)
        XCTAssertNil(photo?.thumbnailPhotos)
        XCTAssertNil(photo?.lowResolutionPhotos)
        XCTAssertNil(photo?.standardResolutionPhotos)
    }
    
    func test_photoInfoMapping() {
        let testInfoPhotoJSON = ["url":"test/url", "width":50, "height":50] as [String : Any]
        let photoMap = Map.init(mappingType: .fromJSON, JSON: testInfoPhotoJSON)
        let photoInfo = PhotoInfo.init(map: photoMap)
        XCTAssertNotNil(photoInfo?.url)
        XCTAssertNotNil(photoInfo?.width)
        XCTAssertNotNil(photoInfo?.height)
    }
    
    func test_photoInfoMappingWithBadJSON() {
        let testInfoPhotoJSON = ["url":URL(string:"https://link")!, "width":"50", "height":"50"] as [String : Any]
        let photoMap = Map.init(mappingType: .fromJSON, JSON: testInfoPhotoJSON)
        let photoInfo = PhotoInfo.init(map: photoMap)
        XCTAssertNil(photoInfo?.url)
        XCTAssertNil(photoInfo?.width)
        XCTAssertNil(photoInfo?.height)
    }
    
}
