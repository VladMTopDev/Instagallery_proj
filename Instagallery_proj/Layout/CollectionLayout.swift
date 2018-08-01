//
//  CollectionLayout.swift
//


import UIKit

protocol CollectionLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat
}

class CollectionLayout: UICollectionViewLayout {

    private var cache = [UICollectionViewLayoutAttributes]()
    private var contentHeight: CGFloat = 0.0
    private var width: CGFloat {
        get {
            return collectionView?.bounds.width ?? 0
        }
    }
    
    public var delegate: CollectionLayoutDelegate?
    public var numberOfColums: Int = 1

    override var collectionViewContentSize: CGSize {
        return CGSize(width: width, height: contentHeight)
    }
    
    override func prepare() {
        cache.removeAll()
        contentHeight = 0.0
        let columnWidth = width / CGFloat(numberOfColums)
        
        var xOffsets = [CGFloat]()
        for column in 0..<numberOfColums {
            xOffsets.append(CGFloat(column) * columnWidth)
        }
        
        var yOffsets = [CGFloat](repeating: 0, count: numberOfColums)
        
        var column = 0
        if let collection = collectionView  {
            for item in 0..<collection.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                let height = delegate?.collectionView(collection, heightForItemAt: indexPath)
                let frame = CGRect(x: CGFloat(xOffsets[column]), y: CGFloat(yOffsets[column]) + 5.0, width: columnWidth - 5.0, height: height! - 5.0)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                cache.append(attributes)
                contentHeight = max(contentHeight, frame.maxY)
                yOffsets[column] = CGFloat(yOffsets[column]) + height!
                column = column >= (numberOfColums - 1) ? 0 : column + 1
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
}


