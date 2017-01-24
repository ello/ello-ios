//
//  StreamCollectionViewLayout.swift
//  Ello
//
//  Created by Sean on 1/26/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//  Big thanks to https://github.com/chiahsien
//  Swiftified and modified https://github.com/chiahsien/CHTCollectionViewWaterfallLayout

@objc
protocol StreamCollectionViewLayoutDelegate: UICollectionViewDelegate {

    func collectionView (_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize

    func collectionView (_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        heightForItemAtIndexPath indexPath: IndexPath,
        numberOfColumns: NSInteger) -> CGFloat

    @objc optional func collectionView (_ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        groupForItemAtIndexPath indexPath: IndexPath) -> String?

    @objc optional func colletionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: NSInteger) -> UIEdgeInsets

    @objc optional func colletionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAtIndex section: NSInteger) -> CGFloat

    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        isFullWidthAtIndexPath indexPath: IndexPath) -> Bool
}

class StreamCollectionViewLayout: UICollectionViewLayout {

    enum Direction {
        case shortestFirst
        case leftToRight
        case rightToLeft
    }

    var columnCount: Int {
        didSet { if columnCount != oldValue {
            invalidateLayout()
        } }
    }

    var minimumColumnSpacing: CGFloat {
        didSet { if minimumColumnSpacing != oldValue {
            invalidateLayout()
        } }
    }

    var minimumInteritemSpacing: CGFloat {
        didSet { if minimumInteritemSpacing != oldValue {
            invalidateLayout()
        } }
    }

    var sectionInset: UIEdgeInsets {
        didSet { if sectionInset != oldValue {
            invalidateLayout()
        } }
    }

    var itemRenderDirection: Direction {
        didSet { if itemRenderDirection != oldValue {
            invalidateLayout()
        } }
    }

    var delegate: StreamCollectionViewLayoutDelegate? {
        return collectionView?.delegate as? StreamCollectionViewLayoutDelegate
    }
    var columnHeights = [CGFloat]()
    var sectionItemAttributes = [[UICollectionViewLayoutAttributes]]()
    var allItemAttributes = [UICollectionViewLayoutAttributes]()
    var unionRects = [CGRect]()
    let unionSize = 20

    override init(){
        columnCount = 2
        minimumInteritemSpacing = 0
        minimumColumnSpacing = 12
        sectionInset = UIEdgeInsets.zero
        itemRenderDirection = .shortestFirst
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        columnCount = 2
        minimumInteritemSpacing = 0
        minimumColumnSpacing = 12
        sectionInset = UIEdgeInsets.zero
        itemRenderDirection = .shortestFirst
        super.init(coder: aDecoder)
    }

    override func prepare(){
        super.prepare()

        guard let numberOfSections = self.collectionView?.numberOfSections else {
            return
        }

        unionRects.removeAll()
        columnHeights.removeAll()
        allItemAttributes.removeAll()
        sectionItemAttributes.removeAll()

        for _ in 0..<columnCount {
            self.columnHeights.append(0)
        }

        for section in 0..<numberOfSections {
            addAttributesForSection(section)
        }

        let itemCounts = allItemAttributes.count
        var index = 0
        while index < itemCounts {
            let rect1 = allItemAttributes[index].frame
            index = min(index + unionSize, itemCounts) - 1
            let rect2 = allItemAttributes[index].frame
            unionRects.append(rect1.union(rect2))
            index += 1
        }
    }

    fileprivate func addAttributesForSection(_ section: Int) {

        var attributes = UICollectionViewLayoutAttributes()

        let width = collectionView!.frame.size.width - sectionInset.left - sectionInset.right

        let spaceColumCount = CGFloat(columnCount-1)

        let itemWidth = floor((width - (spaceColumCount * minimumColumnSpacing)) / CGFloat(columnCount))

        let itemCount = collectionView!.numberOfItems(inSection: section)
        var itemAttributes = [UICollectionViewLayoutAttributes]()

        // Item will be put into shortest column.
        var groupIndex = ""
        var currentColumIndex = 0
        for index in 0..<itemCount {
            let indexPath = IndexPath(item: index, section: section)
            let itemGroup: String? = self.delegate?.collectionView?(self.collectionView!, layout: self, groupForItemAtIndexPath: indexPath)
            let isFullWidth = self.delegate?.collectionView?(self.collectionView!, layout: self, isFullWidthAtIndexPath: indexPath) ?? false
            if let itemGroup = itemGroup {
                if itemGroup != groupIndex {
                    groupIndex = itemGroup
                    currentColumIndex = nextColumnIndexForItem(index)
                }
            }
            else {
                currentColumIndex = nextColumnIndexForItem(index)
            }

            var calculatedColumnCount = columnCount
            var calculatedItemWidth = itemWidth
            if isFullWidth {
                calculatedItemWidth = floor(width)
                calculatedColumnCount = 1
                currentColumIndex = 0
            }

            let xOffset = sectionInset.left + (calculatedItemWidth + minimumColumnSpacing) * CGFloat(currentColumIndex)
            let yOffset: CGFloat
            if isFullWidth {
                yOffset = columnHeights.max() ?? 0
             }
             else {
                yOffset = columnHeights[currentColumIndex]
             }

            var itemHeight: CGFloat = 0.0

            if let height = delegate?.collectionView(self.collectionView!, layout: self, heightForItemAtIndexPath: indexPath, numberOfColumns: calculatedColumnCount) {
                itemHeight = height
            }

            attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(x: xOffset, y: yOffset, width: calculatedItemWidth, height: itemHeight)
            itemAttributes.append(attributes)

            allItemAttributes.append(attributes)
            let maxY = attributes.frame.maxY
            if isFullWidth {
                for (index, _) in columnHeights.enumerated() {
                    columnHeights[index] = maxY
                }
            }
            else {
                columnHeights[currentColumIndex] = maxY
            }
        }

        sectionItemAttributes.append(itemAttributes)
    }

    override var collectionViewContentSize: CGSize {
        let numberOfSections = collectionView!.numberOfSections
        if numberOfSections == 0 {
            return .zero
        }

        let contentWidth = self.collectionView!.bounds.size.width
        return CGSize(width: contentWidth, height: CGFloat(columnHeights.max() ?? 0))
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return sectionItemAttributes[indexPath.section][indexPath.item]
    }

    override func layoutAttributesForElements (in rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        var begin = 0
        var end = unionRects.count
        var attrs = [UICollectionViewLayoutAttributes]()

        for i in 0 ..< end {
            if rect.intersects(unionRects[i]) {
                begin = i * unionSize
                break
            }
        }
        for i in (0 ..< self.unionRects.count).reversed() {
            if rect.intersects(unionRects[i]) {
                end = min((i+1) * unionSize, allItemAttributes.count)
                break
            }
        }

        for i in begin ..< end {
            let attr = allItemAttributes[i]
            if rect.intersects(attr.frame) {
                attrs.append(attr)
            }
        }

        return attrs
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: "profileHeader", with: indexPath)
    }

    override func shouldInvalidateLayout (forBoundsChange newBounds: CGRect) -> Bool {
        let oldBounds = collectionView!.bounds
        return newBounds.width != oldBounds.width
    }

    fileprivate func shortestColumnIndex() -> Int {
        return columnHeights.index(of: columnHeights.min()!) ?? 0
    }

    fileprivate func longestColumnIndex () -> NSInteger {
        return columnHeights.index(of: columnHeights.max()!) ?? 0
    }

    fileprivate func nextColumnIndexForItem (_ item: NSInteger) -> Int {
        switch itemRenderDirection {
        case .shortestFirst: return shortestColumnIndex()
        case .leftToRight: return (item % columnCount)
        case .rightToLeft: return (columnCount - 1) - (item % columnCount)
        }
    }
}
