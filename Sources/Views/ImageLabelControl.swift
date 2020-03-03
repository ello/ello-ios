////
///  ImageLabelControl.swift
//

import ElloUIFonts

class ImageLabelControl: Control {
    struct Size {
        static let innerPadding: CGFloat = 5
        static let outerPadding: CGFloat = 5
        static let minWidth: CGFloat = 44
        static let height: CGFloat = 44
    }

    override var intrinsicContentSize: CGSize { return frame.size }

    var normalColor: UIColor = .greyA { didSet { updateText() } }
    var selectedColor: UIColor = .black { didSet { updateText() } }
    var disabledColor: UIColor = .greyC { didSet { updateText() } }

    var title: String? {
        didSet {
            updateText()
            updateLayout()
        }
    }

    override var isSelected: Bool {
        didSet {
            icon.isSelected = isSelected
            updateText()

        }
    }

    override var isHighlighted: Bool {
        didSet {
            icon.isHighlighted = isHighlighted
            updateText()
        }
    }

    override var isEnabled: Bool {
        didSet {
            icon.isEnabled = isEnabled
        }
    }

    let titleFont = UIFont.defaultFont()
    let contentContainer = Container(frame: .zero)
    let label = UILabel(frame: .zero)
    var icon: ImageLabelAnimatable

    init(icon: ImageLabelAnimatable, title: String) {
        self.icon = icon
        super.init(frame: .zero)
        self.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    func animate() {
        self.icon.animate?()
    }

    func finishAnimation() {
        self.icon.finishAnimation?()
    }

    @objc
    func buttonTouchExit() {
        isHighlighted = false
    }

    @objc
    func buttonTouchEnter() {
        isHighlighted = true
    }

    override func arrange() {
        addSubview(contentContainer)

        contentContainer.addSubview(icon.view)
        contentContainer.addSubview(label)
    }

    override func bindActions() {
        contentContainer.isUserInteractionEnabled = false
        addTarget(self, action: #selector(buttonTouchEnter), for: [.touchDown, .touchDragEnter])
        addTarget(
            self,
            action: #selector(buttonTouchExit),
            for: [.touchCancel, .touchDragExit, .touchUpInside]
        )
    }

    private func updateText() {
        let title = self.title ?? ""

        if !isEnabled {
            label.attributedText = NSAttributedString(title, color: disabledColor)
        }
        else if isHighlighted || isSelected {
            label.attributedText = NSAttributedString(title, color: selectedColor)
        }
        else {
            label.attributedText = NSAttributedString(title, color: normalColor)
        }
    }

    private func updateLayout() {
        label.sizeToFit()

        let textWidth = label.frame.width
        let contentWidth = textWidth == 0
            ? icon.view.frame.width : icon.view.frame.width + Size.innerPadding + textWidth

        var totalWidth: CGFloat = contentWidth + Size.outerPadding * 2

        // force a minimum totalWidth of 44 pts
        totalWidth = max(totalWidth, Size.minWidth)

        self.frame.size.width = totalWidth
        self.frame.size.height = Size.height
        invalidateIntrinsicContentSize()

        let iconViewY: CGFloat = Size.height / 2 - icon.view.frame.size.height / 2
        icon.view.frame.origin.y = iconViewY

        let contentX: CGFloat = totalWidth / 2 - contentWidth / 2
        contentContainer.frame =
            CGRect(
                x: contentX,
                y: 0,
                width: contentWidth,
                height: Size.height
            )

        label.frame.origin.x = icon.view.frame.origin.x + icon.view.frame.width + Size.innerPadding
        label.frame.origin.y = Size.height / 2 - label.frame.size.height / 2
    }

    private func attributedText(_ title: String, color: UIColor) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left

        let attributed = NSAttributedString(
            string: title,
            attributes: [
                .font: titleFont,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ]
        )
        return attributed
    }
}
