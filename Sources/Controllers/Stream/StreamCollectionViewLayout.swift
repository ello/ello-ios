////
///  StreamCollectionViewLayout.swift
//
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

    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        isFullWidthAtIndexPath indexPath: IndexPath) -> Bool
}

class StreamCollectionViewLayout: UICollectionViewLayout {
    enum Direction {
        case shortestFirst
        case leftToRight
        case rightToLeft
    }

    var columnCount: Int = 1 {
        didSet { if columnCount != oldValue {
            invalidateLayout()
        } }
    }

    var horizontalColumnSpacing: CGFloat = 0 {
        didSet { if horizontalColumnSpacing != oldValue {
            invalidateLayout()
        } }
    }

    var insets: UIEdgeInsets {
        didSet { if insets != oldValue {
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
        insets = UIEdgeInsets.zero
        itemRenderDirection = .shortestFirst
        super.init()
    }

    required init?(coder: NSCoder) {
        insets = UIEdgeInsets.zero
        itemRenderDirection = .shortestFirst
        super.init(coder: coder)
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

    private func addAttributesForSection(_ section: Int) {

        var attributes = UICollectionViewLayoutAttributes()

        let fullWidth = collectionView!.frame.size.width
        let width = fullWidth - insets.sides
        let spaceColumCount = CGFloat(columnCount-1)
        let itemWidth = floor((width - (spaceColumCount * horizontalColumnSpacing)) / CGFloat(columnCount))
        let itemCount = collectionView!.numberOfItems(inSection: section)
        var itemAttributes = [UICollectionViewLayoutAttributes]()

        // Item will be put into shortest column.
        var groupIndex = ""
        var currentColumnIndex = 0
        for index in 0 ..< itemCount {
            let indexPath = IndexPath(item: index, section: section)
            let itemGroup: String? = self.delegate?.collectionView?(self.collectionView!, layout: self, groupForItemAtIndexPath: indexPath)
            let isFullWidth = self.delegate?.collectionView?(self.collectionView!, layout: self, isFullWidthAtIndexPath: indexPath) ?? false
            if let itemGroup = itemGroup {
                if itemGroup != groupIndex {
                    groupIndex = itemGroup
                    currentColumnIndex = nextColumnIndexForItem(index)
                }
            }
            else {
                currentColumnIndex = nextColumnIndexForItem(index)
            }

            var calculatedColumnCount = columnCount
            var calculatedItemWidth = itemWidth
            if isFullWidth {
                calculatedItemWidth = floor(fullWidth)
                calculatedColumnCount = 1
                currentColumnIndex = 0
            }

            var xOffset = (calculatedItemWidth + horizontalColumnSpacing) * CGFloat(currentColumnIndex)
            if !isFullWidth {
                xOffset += insets.left
            }

            var yOffset: CGFloat
            if isFullWidth {
               yOffset = columnHeights.max() ?? 0
            }
            else {
               yOffset = columnHeights[currentColumnIndex]
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
                for index in columnHeights.indices {
                    columnHeights[index] = maxY
                }
            }
            else {
                columnHeights[currentColumnIndex] = maxY
            }
        }

        sectionItemAttributes.append(itemAttributes)
    }

    override var collectionViewContentSize: CGSize {
        guard
            let collectionView = collectionView,
            collectionView.numberOfSections > 0
        else { return .zero }

        let contentWidth = collectionView.bounds.size.width
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

    private func shortestColumnIndex() -> Int {
        return columnHeights.index(of: columnHeights.min()!) ?? 0
    }

    private func longestColumnIndex () -> NSInteger {
        return columnHeights.index(of: columnHeights.max()!) ?? 0
    }

    private func nextColumnIndexForItem (_ item: NSInteger) -> Int {
        switch itemRenderDirection {
        case .shortestFirst: return shortestColumnIndex()
        case .leftToRight: return (item % columnCount)
        case .rightToLeft: return (columnCount - 1) - (item % columnCount)
        }
    }
}
