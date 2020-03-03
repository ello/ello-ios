////
///  StyledButton.swift
//

class StyledButton: UIButton {
    enum CornerRadius {
        case square
        case pill
        case rounded

        func size(in frame: CGRect) -> CGFloat {
            switch self {
            case .square:
                return 0
            case .pill:
                return min(frame.height, frame.width) / 2
            case .rounded:
                return 5
            }
        }
    }

    struct Style {
        let highlightedBackgroundColor: UIColor?
        let unselectHighlightedBackgroundColor: UIColor?
        let selectedBackgroundColor: UIColor?
        let disabledBackgroundColor: UIColor?
        let backgroundColor: UIColor?

        let highlightedTitleColor: UIColor?
        let unselectHighlightedTitleColor: UIColor?
        let selectedTitleColor: UIColor?
        let disabledTitleColor: UIColor?
        let titleColor: UIColor?

        let highlightedBorderColor: UIColor?
        let unselectHighlightedBorderColor: UIColor?
        let selectedBorderColor: UIColor?
        let disabledBorderColor: UIColor?
        let borderColor: UIColor?

        let font: UIFont
        let cornerRadius: CornerRadius
        let underline: Bool  // used by NSAttributedString

        init(
            backgroundColor: UIColor? = nil,
            highlightedBackgroundColor: UIColor? = nil,
            unselectHighlightedBackgroundColor: UIColor? = nil,
            selectedBackgroundColor: UIColor? = nil,
            disabledBackgroundColor: UIColor? = nil,

            titleColor: UIColor? = nil,
            highlightedTitleColor: UIColor? = nil,
            unselectHighlightedTitleColor: UIColor? = nil,
            selectedTitleColor: UIColor? = nil,
            disabledTitleColor: UIColor? = nil,

            borderColor: UIColor? = nil,
            highlightedBorderColor: UIColor? = nil,
            unselectHighlightedBorderColor: UIColor? = nil,
            selectedBorderColor: UIColor? = nil,
            disabledBorderColor: UIColor? = nil,

            font: UIFont? = nil,
            cornerRadius: CornerRadius = .square,
            underline: Bool = false
        ) {
            self.highlightedBackgroundColor = highlightedBackgroundColor
            self.unselectHighlightedBackgroundColor = unselectHighlightedBackgroundColor
            self.selectedBackgroundColor = selectedBackgroundColor
            self.disabledBackgroundColor = disabledBackgroundColor
            self.backgroundColor = backgroundColor

            self.highlightedTitleColor = highlightedTitleColor
            self.unselectHighlightedTitleColor = unselectHighlightedTitleColor
            self.selectedTitleColor = selectedTitleColor
            self.disabledTitleColor = disabledTitleColor
            self.titleColor = titleColor

            self.highlightedBorderColor = highlightedBorderColor
            self.unselectHighlightedBorderColor = unselectHighlightedBorderColor
            self.selectedBorderColor = selectedBorderColor
            self.disabledBorderColor = disabledBorderColor
            self.borderColor = borderColor

            self.cornerRadius = cornerRadius
            self.underline = underline

            self.font = font ?? .defaultFont()
        }
    }

    var didOverrideTitle = false
    var style: Style = .default {
        didSet { updateStyle() }
    }
    @objc var styleName: String = "default" {
        didSet { style = Style.byName(styleName) }
    }

    override var isEnabled: Bool {
        didSet { updateStyle() }
    }
    override var isHighlighted: Bool {
        didSet { updateStyle() }
    }
    override var isSelected: Bool {
        didSet { updateStyle() }
    }
    var title: String? {
        get { return currentTitle ?? currentAttributedTitle?.string }
        set { setTitle(newValue, for: .normal) }
    }
    var titleLineBreakMode: NSLineBreakMode = .byWordWrapping {
        didSet { updateStyle() }
    }
    var titleAlignment: NSTextAlignment = .center {
        didSet { updateStyle() }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.masksToBounds = true
        layer.cornerRadius = style.cornerRadius.size(in: frame)
    }

    func updateStyle() {
        let layerBorder: UIColor?
        if !isEnabled {
            backgroundColor = style.disabledBackgroundColor ?? style.backgroundColor
            layerBorder = style.disabledBorderColor ?? style.borderColor
        }
        else if isHighlighted && isSelected {
            backgroundColor = style.unselectHighlightedBackgroundColor
                ?? style.highlightedBackgroundColor ?? style.backgroundColor
            layerBorder = style.unselectHighlightedBorderColor ?? style.highlightedBorderColor
                ?? style.borderColor
        }
        else if isHighlighted {
            backgroundColor = style.highlightedBackgroundColor ?? style.backgroundColor
            layerBorder = style.highlightedBorderColor ?? style.borderColor
        }
        else if isSelected {
            backgroundColor = style.selectedBackgroundColor ?? style.backgroundColor
            layerBorder = style.selectedBorderColor ?? style.borderColor
        }
        else {
            backgroundColor = style.backgroundColor
            layerBorder = style.borderColor
        }


        if let layerBorder = layerBorder {
            layer.borderColor = layerBorder.cgColor
            layer.borderWidth = 1
        }
        else {
            layer.borderColor = nil
            layer.borderWidth = 0
        }

        if !didOverrideTitle {
            titleLabel?.font = style.font

            if let defaultTitle = self.title(for: .normal) {
                let states: [UIControl.State] = [.normal, .highlighted, .selected, .disabled]
                for state in states {
                    let title = self.title(for: state) ?? defaultTitle
                    super.setAttributedTitle(
                        NSAttributedString(
                            button: title,
                            style: style,
                            state: state,
                            selected: isSelected,
                            alignment: titleAlignment,
                            lineBreakMode: titleLineBreakMode
                        ),
                        for: state
                    )
                }
            }
        }
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)
        sharedSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedSetup()
    }

    convenience init(style: Style) {
        self.init()
        self.style = style
        updateStyle()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        if buttonType != .custom {
            print(
                "Warning, StyledButton instance '\(self)' should be configured as 'Custom', not \(buttonType)"
            )
        }
    }

    func sharedSetup() {
        titleLabel?.numberOfLines = 1
        updateStyle()
    }
}

extension StyledButton {

    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        updateStyle()
    }

    override func setAttributedTitle(_ title: NSAttributedString?, for state: UIControl.State) {
        super.setAttributedTitle(title, for: state)
        didOverrideTitle = title != nil
        updateStyle()
    }

    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        var titleRect = super.titleRect(forContentRect: contentRect)
        let delta: CGFloat = 4
        titleRect.size.height += 2 * delta
        titleRect.origin.y -= delta
        return titleRect
    }
}

extension StyledButton.Style {
    static let `default` = StyledButton.Style(
        backgroundColor: .black,
        disabledBackgroundColor: .black,
        titleColor: .white,
        disabledTitleColor: .grey6
    )

    static let clearWhite = StyledButton.Style(
        titleColor: .white,
        disabledTitleColor: .greyA
    )
    static let clearDynamic = StyledButton.Style(
        titleColor: .text,
        selectedTitleColor: .selected,
        disabledTitleColor: .greyC
    )
    static let clearBlack = StyledButton.Style(
        titleColor: .black,
        disabledTitleColor: .greyC
    )
    static let clearBlackLarge = StyledButton.Style(
        titleColor: .black,
        disabledTitleColor: .greyC,
        font: .defaultFont(18)
    )
    static let clearGray = StyledButton.Style(
        titleColor: .greyA,
        highlightedTitleColor: .black,
        disabledTitleColor: .greyC
    )
    static let clearGrayDynamic = StyledButton.Style(
        titleColor: .greyA,
        highlightedTitleColor: .text,
        selectedTitleColor: .selected,
        disabledTitleColor: .disabled
    )
    static let clearGreen = StyledButton.Style(
        titleColor: .greenD1,
        highlightedTitleColor: .greyA,
        disabledTitleColor: .greyC
    )
    static let clearOrange = StyledButton.Style(
        titleColor: .orangeC6,
        highlightedTitleColor: .greyA,
        disabledTitleColor: .greyC
    )

    static let grayText = StyledButton.Style(
        titleColor: .greyA
    )
    static let lightGray = StyledButton.Style(
        backgroundColor: .greyE5,
        disabledBackgroundColor: .greyF1,
        titleColor: .grey6,
        highlightedTitleColor: .black,
        disabledTitleColor: .greyC
    )
    static let white = StyledButton.Style(
        backgroundColor: .white,
        selectedBackgroundColor: .black,
        disabledBackgroundColor: .greyA,
        titleColor: .black,
        highlightedTitleColor: .grey6,
        selectedTitleColor: .white,
        disabledTitleColor: .greyC
    )
    static let green = StyledButton.Style(
        backgroundColor: .greenD1,
        disabledBackgroundColor: .greyA,
        titleColor: .white,
        highlightedTitleColor: .black,
        disabledTitleColor: .white,
        cornerRadius: .rounded
    )

    static let whiteUnderlined = StyledButton.Style(
        backgroundColor: .clear,
        titleColor: .white,
        underline: true
    )
    static let smallWhiteUnderlined = StyledButton.Style(
        backgroundColor: .clear,
        titleColor: .white,
        font: .defaultFont(12),
        underline: true
    )
    static let whiteBoldUnderlined = StyledButton.Style(
        backgroundColor: .clear,
        titleColor: .white,
        font: .defaultBoldFont(),
        underline: true
    )
    static let grayUnderlined = StyledButton.Style(
        backgroundColor: .clear,
        titleColor: .greyA,
        underline: true
    )
    static let smallGrayUnderlined = StyledButton.Style(
        backgroundColor: .clear,
        titleColor: .greyA,
        font: .defaultFont(12),
        underline: true
    )

    static let roundedBlackOutline = StyledButton.Style(
        backgroundColor: .clear,
        highlightedBackgroundColor: .black,
        selectedBackgroundColor: .black,
        titleColor: .black,
        highlightedTitleColor: .white,
        disabledTitleColor: .greyA,
        borderColor: .black,
        highlightedBorderColor: .black,
        disabledBorderColor: .greyA,
        cornerRadius: .rounded
    )
    static let roundedGrayOutline = StyledButton.Style(
        backgroundColor: .clear,
        selectedBackgroundColor: .black,
        titleColor: .greyA,
        highlightedTitleColor: .black,
        unselectHighlightedTitleColor: .greyA,
        selectedTitleColor: .white,
        disabledTitleColor: .greyC,
        borderColor: .greyA,
        highlightedBorderColor: .black,
        unselectHighlightedBorderColor: .greyA,
        selectedBorderColor: .black,
        disabledBorderColor: .greyC,
        cornerRadius: .rounded
    )
    static let roundedBlack = StyledButton.Style(
        backgroundColor: .black,
        disabledBackgroundColor: .grey3,
        titleColor: .white,
        disabledTitleColor: .greyC,
        disabledBorderColor: .greyC,
        cornerRadius: .rounded
    )
    static let roundedGray = StyledButton.Style(
        backgroundColor: .greyA,
        titleColor: .white,
        cornerRadius: .rounded
    )
    static let blackPill = StyledButton.Style(
        backgroundColor: .black,
        disabledBackgroundColor: .greyF2,
        titleColor: .white,
        highlightedTitleColor: .grey6,
        disabledTitleColor: .greyC,
        cornerRadius: .pill
    )
    static let blackPillOutline = StyledButton.Style(
        titleColor: .black,
        highlightedTitleColor: .grey6,
        disabledTitleColor: .greyF2,
        borderColor: .black,
        disabledBorderColor: .greyF2,
        cornerRadius: .pill
    )
    static let greenPill = StyledButton.Style(
        backgroundColor: .greenD1,
        disabledBackgroundColor: .greyA,
        titleColor: .white,
        highlightedTitleColor: .greyA,
        disabledTitleColor: .white,
        cornerRadius: .pill
    )
    static let redPill = StyledButton.Style(
        backgroundColor: .red,
        disabledBackgroundColor: .greyA,
        titleColor: .white,
        highlightedTitleColor: .greyA,
        disabledTitleColor: .white,
        cornerRadius: .pill
    )
    static let grayPill = StyledButton.Style(
        backgroundColor: .greyA,
        titleColor: .white,
        cornerRadius: .pill
    )
    static let subscribePill = StyledButton.Style(
        backgroundColor: .greenD1,
        selectedBackgroundColor: .greyA,
        titleColor: .white,
        font: .defaultFont(12),
        cornerRadius: .pill
    )

    static let inviteFriend = StyledButton.Style(
        backgroundColor: .greyA,
        titleColor: .white,
        cornerRadius: .pill
    )
    static let invited = StyledButton.Style(
        backgroundColor: .greyE5,
        titleColor: .grey6,
        cornerRadius: .pill
    )
    static let categoryInfo = StyledButton.Style(
        backgroundColor: .dimmedBlackBackground,
        disabledBackgroundColor: .greyF2,
        titleColor: .white,
        highlightedTitleColor: .grey6,
        disabledTitleColor: .greyC,
        font: .defaultFont(12),
        cornerRadius: .pill
    )
    static let editorialJoin = StyledButton.Style(
        backgroundColor: .greenD1,
        disabledBackgroundColor: UIColor(hex: 0x7AC97A),
        titleColor: .white,
        highlightedTitleColor: .greyA,
        disabledTitleColor: .white,
        cornerRadius: .rounded
    )
    static let notification = StyledButton.Style(
        backgroundColor: .greyE5,
        selectedBackgroundColor: .black,
        titleColor: .greyA,
        selectedTitleColor: .white
    )
    static let subscribed = StyledButton.Style(
        backgroundColor: .greenD1,
        selectedBackgroundColor: .greyA,
        titleColor: .white,
        selectedTitleColor: .white
    )
    static let forgotPassword = StyledButton.Style(
        backgroundColor: .clear,
        titleColor: .greyA,
        font: .defaultFont(11)
    )

    static func byName(_ name: String) -> StyledButton.Style {
        switch name {
        case "lightGray": return .lightGray
        case "inviteFriend": return .inviteFriend
        default: return .default
        }
    }
}
