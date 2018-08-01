//
//  CollectionLayout.swift
//


import Foundation
import XCTest
@testable import Instagallery_proj

class CollectionLayoutTest: XCTestCase {
    
    func test_layoutAttributesForElements_withoutCache() {
        let collectionLayout = CollectionLayout()
        let testRect = CGRect(x:0, y:0, width: 50, height:100)
        XCTAssertNotNil(collectionLayout.layoutAttributesForElements(in: testRect))
    }
    
    func test_layoutAttributesForElements() {
        let collectionLayout = CollectionLayout()
        let _ = UICollectionView.init(frame: CGRect(x:0, y:0, width:325, height: 322), collectionViewLayout: collectionLayout)
        let testRect = CGRect(x:0, y:0, width: 50, height:100)
        let layouts = collectionLayout.layoutAttributesForElements(in: testRect) ?? []
        XCTAssertTrue(layouts.count > 0)
    }
    
}
