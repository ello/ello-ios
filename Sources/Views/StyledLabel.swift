////
///  StyledLabel.swift
//

class StyledLabel: UILabel {
    enum FontFamily {
        case small
        case normal
        case header
        case large
        case largeBold
        case bold
        case categoryHeader
        case editorialHeader
        case editorialSuccess
        case editorialCaption
        case artistInviteTitle
        case artistInviteDetail

        var font: UIFont {
            switch self {
            case .small: return UIFont.defaultFont(12)
            case .normal: return UIFont.defaultFont()
            case .header: return UIFont.regularBlackFont(24)
            case .large: return UIFont.defaultFont(18)
            case .largeBold: return UIFont.defaultBoldFont(18)
            case .bold: return UIFont.defaultBoldFont()
            case .categoryHeader: return UIFont.regularBlackFont(64)
            case .editorialHeader: return UIFont.regularBlackFont(32)
            case .editorialSuccess: return UIFont.regularBlackFont(24)
            case .editorialCaption: return UIFont.defaultFont(16)
            case .artistInviteTitle: return UIFont.regularBlackFont(24)
            case .artistInviteDetail: return UIFont.regularLightFont(24)
            }
        }
    }

    struct Style {
        let backgroundColor: UIColor
        let textColor: UIColor
        let underline: Bool
        let fontFamily: FontFamily

        var font: UIFont {
            return fontFamily.font
        }

        init(
            textColor: UIColor,
            backgroundColor: UIColor = .clear,
            underline: Bool = false,
            fontFamily: FontFamily = .normal
        ) {
            self.textColor = textColor
            self.backgroundColor = backgroundColor
            self.underline = underline
            self.fontFamily = fontFamily
        }
    }

    var extraBottomMargin: CGFloat = 10 {
        didSet { invalidateIntrinsicContentSize() }
    }
    override var text: String? {
        didSet { updateStyle() }
    }
    override var lineBreakMode: NSLineBreakMode {
        didSet { updateStyle() }
    }
    override var textAlignment: NSTextAlignment {
        didSet { updateStyle() }
    }
    var isMultiline: Bool = false {
        didSet {
            if isMultiline {
                numberOfLines = 0
                lineBreakMode = .byWordWrapping
            }
            else {
                numberOfLines = 1
                lineBreakMode = .byTruncatingTail
            }
        }
    }
    var style: Style = .default {
        didSet { updateStyle() }
    }
    @objc var styleName: String = "default" {
        didSet { style = Style.byName(styleName) }
    }

    private func updateStyle() {
        backgroundColor = style.backgroundColor

        font = style.font
        textColor = style.textColor

        if let text = text {
            attributedText = NSAttributedString(label: text, style: style, alignment: textAlignment, lineBreakMode: lineBreakMode)
        }
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)
        textAlignment = .left
        numberOfLines = 1
        lineBreakMode = .byTruncatingTail
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        textAlignment = .left
        updateStyle()
    }

    convenience init(style: Style) {
        self.init()
        self.style = style
        updateStyle()
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height = heightForWidth(size.width) + extraBottomMargin
        return size
    }
}

extension StyledLabel {
    private func heightForWidth(_ width: CGFloat) -> CGFloat {
        return (attributedText?.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading, .truncatesLastVisibleLine],
            context: nil).size.height).map(ceil) ?? 0
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
    static let header = StyledLabel.Style(
        textColor: .black,
        fontFamily: .header
        )
    static let largeWhite = StyledLabel.Style(
        textColor: .white,
        fontFamily: .large
        )
    static let largeBoldWhite = StyledLabel.Style(
        textColor: .white,
        fontFamily: .largeBold
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
        textColor: .greyA
        )
    static let lightGray = StyledLabel.Style(
        textColor: UIColor(hex: 0x9a9a9a)
        )
    static let smallGray = StyledLabel.Style(
        textColor: .greyA,
        fontFamily: .small
        )
    static let smallGrayUnderlined = StyledLabel.Style(
        textColor: .greyA,
        underline: true,
        fontFamily: .small
        )
    static let largeGrayHeader = StyledLabel.Style(
        textColor: .greyA,
        fontFamily: .large
        )
    static let largeBoldGray = StyledLabel.Style(
        textColor: .greyA,
        fontFamily: .largeBold
        )
    static let placeholder = StyledLabel.Style(
        textColor: .greyC,
        fontFamily: .normal
        )
    static let largePlaceholder = StyledLabel.Style(
        textColor: .greyC,
        fontFamily: .large
        )
    static let error = StyledLabel.Style(
        textColor: .red
        )

    static let chosenCommunityButton = StyledLabel.Style(
        textColor: .white, backgroundColor: UIColor.black.withAlphaComponent(0.5)
        )
    static let categoryHeader = StyledLabel.Style(
        textColor: .white,
        fontFamily: .categoryHeader
        )
    static let editorialHeader = StyledLabel.Style(
        textColor: .white,
        fontFamily: .editorialHeader
        )
    static let editorialSuccess = StyledLabel.Style(
        textColor: .white,
        fontFamily: .editorialSuccess
        )
    static let editorialCaption = StyledLabel.Style(
        textColor: .white,
        fontFamily: .editorialCaption
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
