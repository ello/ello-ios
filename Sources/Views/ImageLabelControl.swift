//
//  ImageLabelControl.swift
//  Ello
//
//  Created by Sean on 4/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//
import ElloUIFonts

class ImageLabelControl: UIControl {

    var title: String? {
        get { return self.attributedNormalTitle?.string }
        set {
            if let value = newValue, label.text != value {
                attributedNormalTitle = attributedText(value, color: .greyA())
                attributedSelectedTitle = attributedText(value, color: .black)
                attributedDisabledTitle = attributedText(value, color: .greyC())
                updateLayout()
                updateTextColor()
            }
        }
    }

    override var isSelected: Bool {
        didSet {
            icon.selected = isSelected
            updateTextColor()

        }
    }

    override var isHighlighted: Bool {
        didSet {
            icon.highlighted = isHighlighted
            updateTextColor()
        }
    }

    override var isEnabled: Bool {
        didSet {
            icon.enabled = isEnabled
        }
    }

    let innerPadding: CGFloat = 5
    let outerPadding: CGFloat = 5
    let minWidth: CGFloat = 44
    let height: CGFloat = 44
    let titleFont = UIFont.defaultFont()
    let contentContainer = UIView(frame: .zero)
    let label = UILabel(frame: .zero)
    let button = UIButton(frame: .zero)
    var icon: ImageLabelAnimatable
    var attributedNormalTitle: NSAttributedString!
    var attributedSelectedTitle: NSAttributedString!
    var attributedDisabledTitle: NSAttributedString!

    // MARK: Initializers

    init(icon: ImageLabelAnimatable, title: String) {
        self.icon = icon
        super.init(frame: .zero)
        addSubviews()
        addTargets()
        self.title = title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    func animate() {
        self.icon.animate?()
    }

    func finishAnimation() {
        self.icon.finishAnimation?()
    }

    // MARK: IBActions

    @IBAction func buttonTouchUpInside(_ sender: ImageLabelControl) {
        sendActions(for: .touchUpInside)
        isHighlighted = false
    }

    @IBAction func buttonTouchUpOutside(_ sender: ImageLabelControl) {
        sendActions(for: .touchUpOutside)
        isHighlighted = false
    }

    @IBAction func buttonTouchDown(_ sender: ImageLabelControl) {
        sendActions(for: .touchDown)
        isHighlighted = true
    }

    // MARK: Private

    fileprivate func addSubviews() {
        addSubview(contentContainer)
        addSubview(button)
        contentContainer.addSubview(icon.view)
        contentContainer.addSubview(label)
    }

    fileprivate func addTargets() {
        button.addTarget(self, action: #selector(ImageLabelControl.buttonTouchUpInside(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(ImageLabelControl.buttonTouchDown(_:)), for: [.touchDown, .touchDragEnter])
        button.addTarget(self, action: #selector(ImageLabelControl.buttonTouchUpOutside(_:)), for: [.touchCancel, .touchDragExit])
    }

    fileprivate func updateTextColor() {
        if !isEnabled {
            label.attributedText = attributedDisabledTitle
        }
        else if isHighlighted || isSelected {
            label.attributedText = attributedSelectedTitle
        }
        else {
            label.attributedText = attributedNormalTitle
        }
    }

    fileprivate func updateLayout() {
        label.attributedText = attributedNormalTitle
        label.sizeToFit()

        let textWidth = attributedNormalTitle.widthForHeight(0)
        let contentWidth = textWidth == 0 ?
            icon.view.frame.width :
            icon.view.frame.width + textWidth + innerPadding

        var width: CGFloat = contentWidth + outerPadding * 2

        // force a minimum width of 44 pts
        width = max(width, minWidth)

        self.frame.size.width = width
        self.frame.size.height = height

        let iconViewY: CGFloat = height / 2 - icon.view.frame.size.height / 2
        icon.view.frame.origin.y = iconViewY

        let contentX: CGFloat = width / 2 - contentWidth / 2
        contentContainer.frame =
            CGRect(
                x: contentX,
                y: 0,
                width: contentWidth,
                height: height
            )

        button.frame.size.width = width
        button.frame.size.height = height

        label.frame.origin.x = icon.view.frame.origin.x + icon.view.frame.width + innerPadding
        label.frame.origin.y = height / 2 - label.frame.size.height / 2
    }

    fileprivate func attributedText(_ title: String, color: UIColor) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: title)
        let range = NSRange(location: 0, length: title.characters.count)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left

        let attributes = [
            NSFontAttributeName : titleFont,
            NSForegroundColorAttributeName : color,
            NSParagraphStyleAttributeName : paragraphStyle
        ]
        attributed.addAttributes(attributes, range: range)
        return attributed
    }
}
