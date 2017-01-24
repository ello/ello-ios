////
///  StyledButton.swift
//

class StyledButton: UIButton {
    struct Style {
        let disabledBackgroundColor: UIColor?
        let highlightedBackgroundColor: UIColor?
        let selectedBackgroundColor: UIColor?
        let backgroundColor: UIColor?

        let disabledTitleColor: UIColor?
        let selectedTitleColor: UIColor?
        let highlightedTitleColor: UIColor?
        let titleColor: UIColor?

        let highlightedBorderColor: UIColor?
        let selectedBorderColor: UIColor?
        let borderColor: UIColor?
        let disabledBorderColor: UIColor?

        let fontSize: CGFloat?
        let cornerRadius: CGFloat?
        let underline: Bool

        var font: UIFont {
            guard let size = fontSize else {
                return UIFont.defaultFont()
            }
            return UIFont.defaultFont(size)
        }

        init(
            backgroundColor: UIColor? = nil,
            highlightedBackgroundColor: UIColor? = nil,
            selectedBackgroundColor: UIColor? = nil,
            disabledBackgroundColor: UIColor? = nil,

            titleColor: UIColor? = nil,
            highlightedTitleColor: UIColor? = nil,
            selectedTitleColor: UIColor? = nil,
            disabledTitleColor: UIColor? = nil,

            borderColor: UIColor? = nil,
            highlightedBorderColor: UIColor? = nil,
            selectedBorderColor: UIColor? = nil,
            disabledBorderColor: UIColor? = nil,

            fontSize: CGFloat? = nil,
            cornerRadius: CGFloat? = 0,
            underline: Bool = false
        ) {
            self.disabledBackgroundColor = disabledBackgroundColor
            self.highlightedBackgroundColor = highlightedBackgroundColor
            self.selectedBackgroundColor = selectedBackgroundColor
            self.backgroundColor = backgroundColor

            self.disabledTitleColor = disabledTitleColor
            self.highlightedTitleColor = highlightedTitleColor
            self.selectedTitleColor = selectedTitleColor
            self.titleColor = titleColor

            self.disabledBorderColor = disabledBorderColor
            self.highlightedBorderColor = highlightedBorderColor
            self.selectedBorderColor = selectedBorderColor
            self.borderColor = borderColor

            self.fontSize = fontSize
            self.cornerRadius = cornerRadius
            self.underline = underline
        }
    }

    var style: Style = .Default {
        didSet { updateStyle() }
    }
    var styleName: String = "Default" {
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
        get { return currentTitle }
        set { setTitle(newValue, for: .normal) }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let cornerRadius = style.cornerRadius {
            layer.cornerRadius = cornerRadius
        }
        else {
            layer.cornerRadius = min(frame.height, frame.width) / 2
        }
    }

    fileprivate func updateStyle() {
        let layerBorder: UIColor?
        if !isEnabled {
            backgroundColor = style.disabledBackgroundColor ?? style.backgroundColor
            layerBorder = style.disabledBorderColor ?? style.borderColor
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

        titleLabel?.font = style.font

        if let title = self.title(for: .normal) {
            let states: [UIControlState] = [.normal, .disabled, .highlighted, .selected]
            for state in states {
                let attrdTitle = NSAttributedString(button: title, style: style, state: state)
                setAttributedTitle(attrdTitle, for: state)
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
            print("Warning, StyledButton instance '\(currentTitle)' should be configured as 'Custom', not \(buttonType)")
        }
    }

    func sharedSetup() {
        titleLabel?.numberOfLines = 1
        updateStyle()
    }
}

extension StyledButton {

    override func setTitle(_ title: String?, for state: UIControlState) {
        super.setTitle(title, for: state)
        if state == .normal {
            updateStyle()
        }
        else {
            fatalError("StyledButton doesn't support titles that aren't .normal")
        }
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
    static let Default = StyledButton.Style(
        backgroundColor: .black, disabledBackgroundColor: .grey231F20(),
        titleColor: .white, disabledTitleColor: .greyA()
        )
    static let ClearWhite = StyledButton.Style(
        titleColor: .white, disabledTitleColor: .greyA()
        )
    static let ClearBlack = StyledButton.Style(
        titleColor: .black, disabledTitleColor: .greyC()
        )
    static let LightGray = StyledButton.Style(
        backgroundColor: .greyE5(), disabledBackgroundColor: .greyF1(),
        titleColor: .grey6(), highlightedTitleColor: .black, disabledTitleColor: .greyC()
        )
    static let White = StyledButton.Style(
        backgroundColor: .white, disabledBackgroundColor: .greyA(),
        titleColor: .black, highlightedTitleColor: .grey6(), disabledTitleColor: .greyC()
        )
    static let WhiteUnderlined = StyledButton.Style(
        backgroundColor: .clear,
        titleColor: .white,
        underline: true
        )
    static let SquareBlack = StyledButton.Style(
        backgroundColor: .white, selectedBackgroundColor: .black, disabledBackgroundColor: .greyA(),
        titleColor: .black, highlightedTitleColor: .grey6(), selectedTitleColor: .white, disabledTitleColor: .greyC(),
        borderColor: .black, highlightedBorderColor: .greyE5()
        )
    static let BlackPill = StyledButton.Style(
        backgroundColor: .black, disabledBackgroundColor: .greyF2(),
        titleColor: .white, highlightedTitleColor: .grey6(), disabledTitleColor: .greyC(),
        cornerRadius: nil
        )
    static let BlackPillOutline = StyledButton.Style(
        titleColor: .black, highlightedTitleColor: .grey6(), disabledTitleColor: .greyF2(),
        borderColor: .black, disabledBorderColor: .greyF2(),
        cornerRadius: nil
        )
    static let RoundedGray = StyledButton.Style(
        backgroundColor: .clear,
        titleColor: .greyA(), highlightedTitleColor: .black,
        borderColor: .greyA(),
        cornerRadius: 5
        )
    static let InviteFriend = StyledButton.Style(
        backgroundColor: .greyA(),
        titleColor: .white,
        cornerRadius: nil
        )
    static let Invited = StyledButton.Style(
        backgroundColor: .greyE5(),
        titleColor: .grey6(),
        cornerRadius: nil
        )
    static let BlockUserModal = StyledButton.Style(
        backgroundColor: .white, selectedBackgroundColor: .black, disabledBackgroundColor: .greyA(),
        titleColor: .black, highlightedTitleColor: .grey6(), selectedTitleColor: .white, disabledTitleColor: .greyC()
        )
    static let GrayText = StyledButton.Style(
        titleColor: .greyA()
        )
    static let Green = StyledButton.Style(
        backgroundColor: .greenD1(), disabledBackgroundColor: .grey6(),
        titleColor: .white, highlightedTitleColor: .greyA(), disabledTitleColor: .white,
        cornerRadius: 5
        )
    static let GreenPill = StyledButton.Style(
        backgroundColor: .greenD1(), disabledBackgroundColor: .grey6(),
        titleColor: .white, highlightedTitleColor: .greyA(), disabledTitleColor: .white,
        cornerRadius: nil
        )
    static let RedPill = StyledButton.Style(
        backgroundColor: .red, disabledBackgroundColor: .grey6(),
        titleColor: .white, highlightedTitleColor: .greyA(), disabledTitleColor: .white,
        cornerRadius: nil
        )
    static let GrayPill = StyledButton.Style(
        backgroundColor: .greyA(),
        titleColor: .white,
        cornerRadius: nil
        )

    static func byName(_ name: String) -> StyledButton.Style {
        switch name {
        case "LightGray": return .LightGray
        case "White": return .White
        case "WhiteUnderlined": return .WhiteUnderlined
        case "SquareBlack": return .SquareBlack
        case "BlackPill": return .BlackPill
        case "RoundedGray": return .RoundedGray
        case "InviteFriend": return .InviteFriend
        case "Invited": return .Invited
        case "BlockUserModal": return .BlockUserModal
        case "GrayText": return .GrayText
        case "Green": return .Green
        default: return .Default
        }
    }
}
