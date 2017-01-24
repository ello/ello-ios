////
///  NewElloTabBar.swift
//

class NewElloTabBar: UIView {
    enum Alignment {
        case left
        case right
    }

    enum Display {
        case title(String)
        case image(InterfaceImage)
    }

    struct Item {
        let alignment: Alignment
        let display: Display
        let redDotHidden: Bool

        var title: String? {
            switch display {
            case let .title(title): return title
            default: return nil
            }
        }

        var interfaceImage: InterfaceImage? {
            switch display {
            case let .image(interfaceImage): return interfaceImage
            default: return nil
            }
        }
    }

    class ItemView: UIView {
        struct Size {
            static let redDotRadius: CGFloat = 2
        }

        let item: Item
        var selected: Bool = false {
            didSet { updateContentView() }
        }

        fileprivate let contentView: UIView
        fileprivate let underlineView: UIView?
        fileprivate let redDot: UIView = {
            let v = UIView()
            v.backgroundColor = .red
            return v
        }()

        init(item: Item) {
            self.item = item

            switch item.display {
            case .title:
                let label = StyledLabel(style: .Black)
                self.contentView = label
                let underlineView = UIView()
                underlineView.backgroundColor = UIColor.black
                self.underlineView = underlineView
            case .image:
                self.contentView = UIImageView()
                self.underlineView = nil
            }

            super.init(frame: .zero)

            if !item.redDotHidden {
                addSubview(redDot)
            }
            addSubview(contentView)
            if let underlineView = underlineView {
                addSubview(underlineView)
            }

            updateContentView()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        fileprivate func updateContentView() {
            switch item.display {
            case let .title(title):
                let titleView = self.contentView as! StyledLabel
                titleView.style = selected ? .Black : .Gray
                titleView.text = title
                titleView.clipsToBounds = false
            case let .image(interfaceImage):
                let imageView = self.contentView as! UIImageView
                let actualImage = selected ? interfaceImage.selectedImage : interfaceImage.normalImage
                imageView.image = actualImage
            }
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            let contentSize = contentView.intrinsicContentSize
            let actualSize = CGSize(width: contentSize.width + 2, height: contentSize.height + 2)
            contentView.frame = CGRect(
                x: (bounds.width - actualSize.width) / 2,
                y: (bounds.height - actualSize.height) / 2,
                width: actualSize.width,
                height: actualSize.height
                )
            let radius = Size.redDotRadius
            let offset: CGPoint
            switch item.display {
            case .title:
                offset = CGPoint(x: 0, y: 12.5)
            case .image:
                offset = CGPoint(x: -3.5, y: 12.5)
            }
            redDot.frame = CGRect(
                x: contentView.frame.maxX + offset.x,
                y: offset.y,
                width: radius * 2,
                height: radius * 2
                )
            redDot.layer.cornerRadius = radius

            if let underlineView = underlineView {
                underlineView.isHidden = !selected
                underlineView.frame = CGRect(
                    x: (bounds.width - contentSize.width) / 2,
                    y: bounds.height - 14,
                    width: contentSize.width,
                    height: 2.5
                    )
            }
        }

        override var intrinsicContentSize: CGSize {
            var contentSize = self.contentView.intrinsicContentSize
            switch item.display {
            case .title:
                contentSize.width += 11  // margins for the red dot
            case .image:
                contentSize.width = 24  // icon + red dot size
            }
            contentSize.height = 50  // tab bar height
            return contentSize
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    fileprivate func setup() {
        backgroundColor = .white
    }

    var itemViews: [ItemView] = []
    var items: [Item] {
        get { return itemViews.map { $0.item } }
        set {
            for view in itemViews {
                view.removeFromSuperview()
            }
            itemViews = generateItemViews(newValue)
            for view in itemViews {
                addSubview(view)
            }
        }
    }
    var selectedIndex: Int? {
        didSet {
            for view in itemViews {
                view.selected = false
            }
            if let index = selectedIndex, let view = itemViews.safeValue(index) {
                view.selected = true
            }
        }
    }

    fileprivate func generateItemViews(_ items: [Item]) -> [ItemView] {
        return items.map { item in
            return ItemView(item: item)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let tweenMargin: CGFloat = 10

        var left: CGFloat = 15
        let leftViews = itemViews.filter { view in
            return view.item.alignment == .left
        }
        for view in leftViews {
            let size = view.intrinsicContentSize
            view.frame.origin = CGPoint(x: left, y: 0)
            view.frame.size = size
            left += size.width + tweenMargin
        }

        var right: CGFloat = bounds.width - 15
        let rightViews = itemViews.filter { view in
            return view.item.alignment == .right
        }
        for view in rightViews.reversed() {
            let size = view.intrinsicContentSize
            right -= size.width
            view.frame.origin = CGPoint(x: right, y: 0)
            view.frame.size = size
            right -= tweenMargin
        }
    }

}
