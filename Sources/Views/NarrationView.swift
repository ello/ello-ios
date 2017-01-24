////
///  NarrationView.swift
//

class NarrationView: UIView {
    struct Size {
        static let margins = CGFloat(15)
        static let height = CGFloat(112)
        static let pointer = CGSize(width: 12, height: 6)
    }
    fileprivate let closeButton: StyledButton = {
        let closeButton = StyledButton()
        closeButton.setTitle("\u{2573}", for: .normal)
        closeButton.sizeToFit()
        closeButton.isUserInteractionEnabled = false
        return closeButton
    }()
    fileprivate let bg: UIView = {
        let bg = UIView()
        bg.backgroundColor = .black
        return bg
    }()
    fileprivate let label: ElloTextView = {
        let label = ElloTextView()
        label.isUserInteractionEnabled = false
        label.isEditable = false
        label.allowsEditingTextAttributes = false
        label.isSelectable = false
        label.textColor = .white
        label.textContainer.lineFragmentPadding = 0
        label.backgroundColor = .clear
        return label
    }()
    fileprivate let pointer: UIImageView = {
        let pointer = UIImageView()
        pointer.contentMode = .scaleAspectFit
        pointer.image = InterfaceImage.narrationPointer.normalImage
        return pointer
    }()

    var pointerX: CGFloat {
        get { return pointer.frame.midX }
        set { pointer.frame.origin.x = newValue - pointer.frame.size.width / 2 }
    }

    var title: String = "" {
        didSet {
            updateTitleAndText()
        }
    }
    var text: String = "" {
        didSet {
            updateTitleAndText()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bg)
        addSubview(pointer)
        addSubview(label)
        addSubview(closeButton)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func updateTitleAndText() {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 6

        let titleAttributes = [
            NSFontAttributeName : UIFont.defaultBoldFont(),
            NSForegroundColorAttributeName : UIColor.white,
            NSParagraphStyleAttributeName : style
        ]
        let textAttributes = [
            NSFontAttributeName : UIFont.defaultFont(),
            NSForegroundColorAttributeName : UIColor.white,
            NSParagraphStyleAttributeName : style
        ]

        label.attributedText = NSMutableAttributedString(string: title + "\n", attributes: titleAttributes) + NSMutableAttributedString(string: text, attributes: textAttributes)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        pointer.frame.size = Size.pointer
        pointer.frame.origin.y = bounds.height - pointer.frame.height

        closeButton.frame.origin = CGPoint(
            x: bounds.width - Size.margins - closeButton.frame.width,
            y: Size.margins
            )

        bg.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: bounds.height - pointer.frame.height
            )
        label.frame = bg.frame.inset(top: Size.margins, left: Size.margins, bottom: 0, right: 2 * Size.margins + closeButton.frame.width)
    }

}
