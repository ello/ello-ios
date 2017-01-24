////
///  StyledLabel.swift
//

class StyledLabel: UILabel {
    enum FontFamily {
        case small
        case normal
        case large
        case largeBold
        case bold

        var font: UIFont {
            switch self {
            case .small: return UIFont.defaultFont(12)
            case .normal: return UIFont.defaultFont()
            case .large: return UIFont.defaultFont(18)
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
    var style: Style = .Default {
        didSet { updateStyle() }
    }
    var styleName: String = "Default" {
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
    static let Default = StyledLabel.Style(
        textColor: .black
        )
    static let SmallWhite = StyledLabel.Style(
        textColor: .white,
        fontFamily: .small
        )
    static let White = StyledLabel.Style(
        textColor: .white
        )
    static let BoldWhite = StyledLabel.Style(
        textColor: .white,
        fontFamily: .bold
        )
    static let LargeWhite = StyledLabel.Style(
        textColor: .white,
        fontFamily: .largeBold
        )
    static let Black = StyledLabel.Style(
        textColor: .black
        )
    static let Large = StyledLabel.Style(
        textColor: .black,
        fontFamily: .largeBold
        )
    static let Gray = StyledLabel.Style(
        textColor: .greyA()
        )
    static let LightGray = StyledLabel.Style(
        textColor: UIColor(hex: 0x9a9a9a)
        )
    static let LargePlaceholder = StyledLabel.Style(
        textColor: .greyC(),
        fontFamily: .large
        )
    static let Error = StyledLabel.Style(
        textColor: .red
        )

    static func byName(_ name: String) -> StyledLabel.Style {
        switch name {
        case "SmallWhite": return .SmallWhite
        case "White": return .White
        case "BoldWhite": return .BoldWhite
        case "LargeWhite": return .LargeWhite

        case "Black": return .Black
        case "Large": return .Large

        case "Gray": return .Gray
        case "LightGray": return .LightGray

        case "Error": return .Error

        default: return .Default
        }
    }
}
