////
///  ElloNavigationBar.swift
//

class ElloNavigationBar: UINavigationBar {
    struct Size {
        static let height: CGFloat = 64
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        privateInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        privateInit()
    }

    fileprivate func privateInit() {
        self.tintColor = UIColor.greyA()
        self.clipsToBounds = true
        self.shadowImage = UIImage.imageWithColor(UIColor.white)
        self.backgroundColor = UIColor.white
        self.isTranslucent = false
        self.isOpaque = true
        self.barTintColor = UIColor.white

        let bar = BlackBar(frame: CGRect(x: 0, y: 0, width: frame.width, height: 20))
        addSubview(bar)
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height = Size.height
        return size
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let navItem = topItem, let items = navItem.rightBarButtonItems {
            var x: CGFloat = frame.width - 5.5
            let width: CGFloat = 39

            let views = items.flatMap { $0.customView }.sorted { $0.frame.maxX > $1.frame.maxX }
            for view in views {
                x -= width
                view.frame = CGRect(
                    x: x,
                    y: view.frame.y,
                    width: width,
                    height: view.frame.height
                    )
            }
        }
    }

}
