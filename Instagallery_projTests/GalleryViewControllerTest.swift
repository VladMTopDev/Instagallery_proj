//
//  GalleryViewControllerTest.swift
//


import Foundation
import XCTest
import ObjectMapper

@testable import Instagallery_proj

class GalleryViewControllerTest: XCTestCase {
    
    func test_viewDidLoad() {
        let galleryVC = GalleryViewController()
        let _ = galleryVC.view
        galleryVC.galleryCollectionView.reloadData()
        XCTAssertEqual(galleryVC.galleryCollectionView.numberOfSections, 1)

    }
    
    func test_galleryCollectionViewDataSource() {
        let galleryVC = GalleryViewController()
        let _ = galleryVC.view
        galleryVC.galleryCollectionView.reloadData()
        XCTAssertEqual(galleryVC.galleryCollectionView.numberOfSections, 1)
        XCTAssertEqual(galleryVC.galleryCollectionView.numberOfItems(inSection: 0), galleryVC.galleryPhotos.count)
    }

    func test_galleryCollectionCellForItemAt() {
        let galleryVC =  GalleryViewController()
        let _ = galleryVC.view
        let galleryCollectionView = galleryVC.galleryCollectionView
        galleryCollectionView?.register(UINib.init(nibName: String(describing: PhotoCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        let map = Map.init(mappingType: .fromJSON, JSON: ["created_time":"123", "images":["thumbnail": ["width":200, "height":200, "url":"nil"], "standard_resolution":["width":200, "height":200, "url":"https://testlink.com"], "low_resolution":["width":200, "height":200, "url":"https://testlink.com"]]]) // test photos
        galleryVC.galleryPhotos = [Photo(map:map)!, Photo(map:map)!, Photo(map:map)!]
        galleryCollectionView?.reloadData()
        XCTAssertTrue(galleryCollectionView?.numberOfItems(inSection: 0) == 3) // Should be 3 items
        XCTAssertNotNil(galleryCollectionView?.visibleCells)
        let cell = galleryCollectionView?.cellForItem(at: IndexPath(item: 0, section: 0))
        if let photoCell = cell as? PhotoCollectionViewCell {
            XCTAssertNotNil(photoCell.imageView.image) // Should be not nil
        }
        XCTAssertNil(galleryCollectionView?.cellForItem(at: IndexPath(item: 3, section: 0))) // Should be nil
       
    }
    
}
