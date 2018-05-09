////
///  CategoryCardView.swift
//

class CategoryCardView: View {
    struct Size {
        static let cardSize: CGSize = CGSize(width: 100, height: 68)
        static let smallCardSize: CGSize = CGSize(width: 50, height: 68)
        static let zeroStateCardSize: CGSize = CGSize(width: 300, height: 68)
    }

    static let selectedAlpha: CGFloat = 0.8
    static let normalAlpha: CGFloat = 0.6
    static let darkAlpha: CGFloat = 0.8
    static let fullAlpha: CGFloat = 1.0

    let info: CategoryCardListView.CategoryInfo
    var isSelected: Bool = false { didSet { updateStyle(animated: true) } }

    var overlayAlpha: CGFloat {
        get { return overlay.alpha }
        set { overlay.alpha = newValue }
    }

    private let overlay = UIView()
    let button = UIButton()

    init(info: CategoryCardListView.CategoryInfo) {
        self.info = info
        super.init(frame: .default)
    }

    required init(frame: CGRect) {
        fatalError("use init(info:)")
    }

    required init?(coder: NSCoder) {
        fatalError("use init(info:)")
    }

    override func style() {
        backgroundColor = .white

        overlay.backgroundColor = .black
        button.titleLabel?.numberOfLines = 0

        updateStyle(animated: false)
    }

    override func arrange() {
        if let url = info.imageURL {
            let imageView = UIImageView()
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.pin_setImage(from: url)
            addSubview(imageView)
            imageView.snp.makeConstraints { $0.edges.equalTo(self) }
        }

        switch info.kind {
        case .all:
            snp.makeConstraints { make in
                make.size.equalTo(Size.smallCardSize)
            }
        case .subscribed:
            let imageView = UIImageView(image: UIImage(named: "subscribed-background"))
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            addSubview(imageView)
            imageView.snp.makeConstraints { $0.edges.equalTo(self) }

            snp.makeConstraints { make in
                make.size.equalTo(Size.cardSize)
            }
        case .zeroState:
            let gradient = CategoryCardView.generateGradientLayer()
            gradient.frame.size = Size.zeroStateCardSize
            layer.addSublayer(gradient)

            snp.makeConstraints { make in
                make.size.equalTo(Size.zeroStateCardSize)
            }
        case .category:
            snp.makeConstraints { make in
                make.size.equalTo(Size.cardSize)
            }
        }

        addSubview(overlay)
        addSubview(button)

        overlay.snp.makeConstraints { $0.edges.equalTo(self) }
        button.snp.makeConstraints { $0.edges.equalTo(self).inset(5) }
    }

    private func updateStyle(animated: Bool) {
        let alpha: CGFloat
        if isSelected, info.isAll {
            alpha = CategoryCardView.fullAlpha
        }
        else if isSelected {
            alpha = CategoryCardView.selectedAlpha
        }
        else if info.isAll {
            alpha = CategoryCardView.darkAlpha
        }
        else {
            alpha = CategoryCardView.normalAlpha
        }

        elloAnimate(animated: animated) {
            self.overlay.alpha = alpha
        }

        let attributedString: NSAttributedString
        if info.isZeroState {
            let attributedString1 = NSAttributedString(
                button: InterfaceString.Discover.ZeroState1,
                style: .clearWhite,
                state: .normal
                )
            let attributedString2 = NSAttributedString(
                button: InterfaceString.Discover.ZeroState2,
                style: .whiteUnderlined,
                state: .normal
                )
            let attributedString3 = NSAttributedString(
                button: InterfaceString.Discover.ZeroState3,
                style: .clearWhite,
                state: .normal
                )
            attributedString = attributedString1 + attributedString2 + attributedString3
        }
        else {
            attributedString = NSAttributedString(
                button: info.title,
                style: isSelected ? .whiteBoldUnderlined : .clearWhite,
                state: .normal
                )
        }
        button.setAttributedTitle(attributedString, for: .normal)
    }
}

extension CategoryCardView {
    func addTarget(_ target: Any?, action: Selector) {
        button.addTarget(target, action: action, for: .touchUpInside)
    }
}

extension CategoryCardView {
    private static func generateGradientLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.locations = [0, NSNumber(value: CategoryScreen.Size.gradientMidpoint), 1]
        layer.colors = [
            UIColor(hex: 0xD300BD, alpha: 1).cgColor,
            UIColor(hex: 0xd200ff, alpha: 1).cgColor,
            UIColor(hex: 0x0063ff, alpha: 1).cgColor,
            UIColor(hex: 0x00ffc1, alpha: 1).cgColor,
            UIColor(hex: 0x0BFF66, alpha: 1).cgColor,
            UIColor(hex: 0x22FF51, alpha: 1).cgColor,
        ]
        layer.locations = [
            0,
            0.08,
            0.40,
            0.70,
            0.96,
            1,
        ]
        layer.startPoint = CGPoint(x: 0, y: 0.51)
        layer.endPoint = CGPoint(x: 1, y: 0.49)
        return layer
    }
}
