////
///  StyledLabel.swift
//

class StyledLabel: UILabel {
    enum FontFamily {
        case small
        case normal
        case large
        case larger
        case giant
        case largeBold
        case bold

        var font: UIFont {
            switch self {
            case .small: return UIFont.defaultFont(12)
            case .normal: return UIFont.defaultFont()
            case .large: return UIFont.defaultFont(18)
            case .larger: return UIFont.defaultFont(24)
            case .giant: return UIFont.defaultFont(48)
            case .largeBold: return UIFont.defaultBoldFont(18)
            case .bold: return UIFont.defaultBoldFont()
            }
        }
    }

    struct Style {
        let backgroundColor: UIColor
        let textColor: UIColor
        let fontFamily: FontFamily

        var font: UIFont {
            return fontFamily.font
        }

        init(
            textColor: UIColor,
            backgroundColor: UIColor = .clear,

            fontFamily: FontFamily = .normal
        ) {
            self.textColor = textColor
            self.backgroundColor = backgroundColor

            self.fontFamily = fontFamily
        }
    }

    struct Size {
        static let extraBottomMargin: CGFloat = 10
    }

    override var text: String? {
        didSet { updateStyle() }
    }
    var style: Style = .default {
        didSet { updateStyle() }
    }
    var styleName: String = "default" {
        didSet { style = Style.byName(styleName) }
    }

    fileprivate func updateStyle() {
        backgroundColor = style.backgroundColor

        font = style.font
        textColor = style.textColor

        if let text = text {
            attributedText = NSAttributedString(label: text, style: style)
        }
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)
        updateStyle()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateStyle()
    }

    convenience init(style: Style) {
        self.init()
        self.style = style
        updateStyle()
    }
}

// MARK: UIView Overrides
extension StyledLabel {

    fileprivate func heightForWidth(_ width: CGFloat) -> CGFloat {
        return (attributedText?.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil).size.height).map(ceil) ?? 0
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height = heightForWidth(size.width) + Size.extraBottomMargin
        return size
    }
}

extension StyledLabel.Style {
    static let `default` = StyledLabel.Style(
        textColor: .black
        )
    static let smallWhite = StyledLabel.Style(
        textColor: .white,
        fontFamily: .small
        )
    static let white = StyledLabel.Style(
        textColor: .white
        )
    static let boldWhite = StyledLabel.Style(
        textColor: .white,
        fontFamily: .bold
        )
    static let largeWhite = StyledLabel.Style(
        textColor: .white,
        fontFamily: .large
        )
    static let largerWhite = StyledLabel.Style(
        textColor: .white,
        fontFamily: .larger
        )
    static let largeBoldWhite = StyledLabel.Style(
        textColor: .white,
        fontFamily: .largeBold
        )
    static let giantWhite = StyledLabel.Style(
        textColor: .white,
        fontFamily: .giant
        )
    static let black = StyledLabel.Style(
        textColor: .black
        )
    static let large = StyledLabel.Style(
        textColor: .black,
        fontFamily: .large
        )
    static let largeBold = StyledLabel.Style(
        textColor: .black,
        fontFamily: .largeBold
        )
    static let gray = StyledLabel.Style(
        textColor: .greyA()
        )
    static let lightGray = StyledLabel.Style(
        textColor: UIColor(hex: 0x9a9a9a)
        )
    static let largeGrayHeader = StyledLabel.Style(
        textColor: UIColor.greyA(),
        fontFamily: .large
        )
    static let placeholder = StyledLabel.Style(
        textColor: .greyC(),
        fontFamily: .normal
        )
    static let largePlaceholder = StyledLabel.Style(
        textColor: .greyC(),
        fontFamily: .large
        )
    static let error = StyledLabel.Style(
        textColor: .red
        )

    static func byName(_ name: String) -> StyledLabel.Style {
        switch name {
        case "white": return .white
        case "black": return .black
        case "gray": return .gray
        case "lightGray": return .lightGray
        case "error": return .error
        default: return .default
        }
    }
}
