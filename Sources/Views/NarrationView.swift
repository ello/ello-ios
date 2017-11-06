////
///  NarrationView.swift
//

class NarrationView: UIView {
    struct Size {
        static let margins = CGFloat(15)
        static let height = CGFloat(112)
        static let pointer = CGSize(width: 12, height: 6)
    }
    private let closeButton: StyledButton = {
        let closeButton = StyledButton()
        closeButton.setTitle("\u{2573}", for: .normal)
        closeButton.sizeToFit()
        closeButton.isUserInteractionEnabled = false
        return closeButton
    }()
    private let bg: UIView = {
        let bg = UIView()
        bg.backgroundColor = .black
        return bg
    }()
    private let label: ElloTextView = {
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
    private let pointer: UIImageView = {
        let pointer = UIImageView()
        pointer.contentMode = .scaleAspectFit
        pointer.interfaceImage = .narrationPointer
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

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateTitleAndText() {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 6

        let titleAttributes: [NSAttributedStringKey: Any] = [
            .font: UIFont.defaultBoldFont(),
            .foregroundColor: UIColor.white,
            .paragraphStyle: style
        ]
        let textAttributes: [NSAttributedStringKey: Any] = [
            .font: UIFont.defaultFont(),
            .foregroundColor: UIColor.white,
            .paragraphStyle: style
        ]

        label.attributedText = NSAttributedString(string: title + "\n", attributes: titleAttributes) + NSAttributedString(string: text, attributes: textAttributes)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        pointer.frame.size = Size.pointer
        pointer.frame.origin.y = bounds.height - pointer.frame.height - 2

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
