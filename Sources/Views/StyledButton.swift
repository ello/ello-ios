////
///  StyledButton.swift
//

class StyledButton: UIButton {
    struct Style {
        let highlightedBackgroundColor: UIColor?
        let selectedBackgroundColor: UIColor?
        let disabledBackgroundColor: UIColor?
        let backgroundColor: UIColor?

        let highlightedTitleColor: UIColor?
        let selectedTitleColor: UIColor?
        let disabledTitleColor: UIColor?
        let titleColor: UIColor?

        let highlightedBorderColor: UIColor?
        let selectedBorderColor: UIColor?
        let disabledBorderColor: UIColor?
        let borderColor: UIColor?

        let fontSize: CGFloat?
        let cornerRadius: CGFloat?
        let underline: Bool  // used by NSAttributedString

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
            self.highlightedBackgroundColor = highlightedBackgroundColor
            self.selectedBackgroundColor = selectedBackgroundColor
            self.disabledBackgroundColor = disabledBackgroundColor
            self.backgroundColor = backgroundColor

            self.highlightedTitleColor = highlightedTitleColor
            self.selectedTitleColor = selectedTitleColor
            self.disabledTitleColor = disabledTitleColor
            self.titleColor = titleColor

            self.highlightedBorderColor = highlightedBorderColor
            self.selectedBorderColor = selectedBorderColor
            self.disabledBorderColor = disabledBorderColor
            self.borderColor = borderColor

            self.fontSize = fontSize
            self.cornerRadius = cornerRadius
            self.underline = underline
        }
    }

    var style: Style = .default {
        didSet { updateStyle() }
    }
    var styleName: String = "default" {
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
            let states: [UIControlState] = [.normal, .highlighted, .selected, .disabled]
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
            print("Warning, StyledButton instance '\(String(describing: currentTitle))' should be configured as 'Custom', not \(buttonType)")
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
    static let `default` = StyledButton.Style(
        backgroundColor: .black, disabledBackgroundColor: .grey231F20(),
        titleColor: .white, disabledTitleColor: .greyA()
        )
    static let clearWhite = StyledButton.Style(
        titleColor: .white, disabledTitleColor: .greyA()
        )
    static let clearBlack = StyledButton.Style(
        titleColor: .black, disabledTitleColor: .greyC()
        )
    static let clearGray = StyledButton.Style(
        titleColor: .greyA(), highlightedTitleColor: .black, disabledTitleColor: .greyC()
        )
    static let lightGray = StyledButton.Style(
        backgroundColor: .greyE5(), disabledBackgroundColor: .greyF1(),
        titleColor: .grey6(), highlightedTitleColor: .black, disabledTitleColor: .greyC()
        )
    static let white = StyledButton.Style(
        backgroundColor: .white, selectedBackgroundColor: .black, disabledBackgroundColor: .greyA(),
        titleColor: .black, highlightedTitleColor: .grey6(), selectedTitleColor: .white, disabledTitleColor: .greyC()
        )
    static let whiteUnderlined = StyledButton.Style(
        backgroundColor: .clear,
        titleColor: .white,
        underline: true
        )
    static let grayUnderlined = StyledButton.Style(
        backgroundColor: .clear,
        titleColor: .greyA(),
        underline: true
        )
    static let squareBlack = StyledButton.Style(
        backgroundColor: .white, selectedBackgroundColor: .black, disabledBackgroundColor: .greyA(),
        titleColor: .black, highlightedTitleColor: .grey6(), selectedTitleColor: .white, disabledTitleColor: .greyC(),
        borderColor: .black, highlightedBorderColor: .greyE5()
        )
    static let blackPill = StyledButton.Style(
        backgroundColor: .black, disabledBackgroundColor: .greyF2(),
        titleColor: .white, highlightedTitleColor: .grey6(), disabledTitleColor: .greyC(),
        cornerRadius: nil
        )
    static let blackPillOutline = StyledButton.Style(
        titleColor: .black, highlightedTitleColor: .grey6(), disabledTitleColor: .greyF2(),
        borderColor: .black, disabledBorderColor: .greyF2(),
        cornerRadius: nil
        )
    static let roundedGrayOutline = StyledButton.Style(
        backgroundColor: .clear,
        titleColor: .greyA(), highlightedTitleColor: .black,
        borderColor: .greyA(),
        cornerRadius: 5
        )
    static let roundedGray = StyledButton.Style(
        backgroundColor: .greyA(),
        titleColor: .white,
        cornerRadius: 5
        )
    static let inviteFriend = StyledButton.Style(
        backgroundColor: .greyA(),
        titleColor: .white,
        cornerRadius: nil
        )
    static let invited = StyledButton.Style(
        backgroundColor: .greyE5(),
        titleColor: .grey6(),
        cornerRadius: nil
        )
    static let blockUserModal = StyledButton.Style(
        backgroundColor: .white, selectedBackgroundColor: .black, disabledBackgroundColor: .greyA(),
        titleColor: .black, highlightedTitleColor: .grey6(), selectedTitleColor: .white, disabledTitleColor: .greyC()
        )
    static let grayText = StyledButton.Style(
        titleColor: .greyA()
        )
    static let green = StyledButton.Style(
        backgroundColor: .greenD1(), disabledBackgroundColor: .grey6(),
        titleColor: .white, highlightedTitleColor: .greyA(), disabledTitleColor: .white,
        cornerRadius: 5
        )
    static let editorialJoin = StyledButton.Style(
        backgroundColor: .greenD1(), disabledBackgroundColor: UIColor(hex: 0x7AC97A),
        titleColor: .white, highlightedTitleColor: .greyA(), disabledTitleColor: .white,
        cornerRadius: 5
        )
    static let greenPill = StyledButton.Style(
        backgroundColor: .greenD1(), disabledBackgroundColor: .grey6(),
        titleColor: .white, highlightedTitleColor: .greyA(), disabledTitleColor: .white,
        cornerRadius: nil
        )
    static let redPill = StyledButton.Style(
        backgroundColor: .red, disabledBackgroundColor: .grey6(),
        titleColor: .white, highlightedTitleColor: .greyA(), disabledTitleColor: .white,
        cornerRadius: nil
        )
    static let grayPill = StyledButton.Style(
        backgroundColor: .greyA(),
        titleColor: .white,
        cornerRadius: nil
        )

    static func byName(_ name: String) -> StyledButton.Style {
        switch name {
        case "lightGray": return .lightGray
        case "inviteFriend": return .inviteFriend
        default: return .default
        }
    }
}
