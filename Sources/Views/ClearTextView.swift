////
///  ClearTextView.swift
//

class ClearTextView: UITextView {
    struct Size {
        static let minTextViewHeight: CGFloat = 38
        static let placeholderOffset: CGFloat = 3
    }
    var lineColor: UIColor? = .grey6() {
        didSet {
            if !isFirstResponder {
                line.backgroundColor = lineColor
            }
        }
    }
    var selectedLineColor: UIColor? = .white {
        didSet {
            if isFirstResponder {
                line.backgroundColor = selectedLineColor
            }
        }
    }
    var placeholder: String? {
        get { return placeholderLabel.text }
        set { placeholderLabel.text = newValue }
    }
    override var text: String? {
        didSet {
            textDidChange()
        }
    }
    override var textColor: UIColor? {
        didSet { updateTextStyle() }
    }
    override var font: UIFont? {
        didSet { updateTextStyle() }
    }
    fileprivate var line = UIView()
    fileprivate let placeholderLabel = StyledLabel(style: .LargePlaceholder)
    fileprivate let rightView = UIImageView()
    var validationState = ValidationState.none {
        didSet {
            rightView.image = validationState.imageRepresentation
            rightView.sizeToFit()
            setNeedsLayout()
        }
    }

    required override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        sharedSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedSetup()
    }

    func sharedSetup() {
        backgroundColor = .clear
        font = .defaultFont(18)
        textColor = .white
        textContainerInset = UIEdgeInsets(top: 2.5, left: -5, bottom: 0, right: 30)
        updateTextStyle()

        addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalTo(self).offset(Size.placeholderOffset)
            make.leading.trailing.equalTo(self)
        }

        addSubview(line)
        line.backgroundColor = lineColor

        addSubview(rightView)
    }

    func textDidChange() {
        placeholderLabel.isHidden = text?.isEmpty == false
        invalidateIntrinsicContentSize()
    }

    fileprivate func updateTextStyle() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 12
        var attributes: [String: AnyObject] = [
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        if let font = font {
            attributes[NSFontAttributeName] = font
        }
        if let textColor = textColor {
            attributes[NSForegroundColorAttributeName] = textColor
        }
        typingAttributes = attributes
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        rightView.frame.origin = CGPoint(x: frame.size.width - rightView.frame.size.width - 10, y: 0)
        line.frame = CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 1)
    }

    override var intrinsicContentSize: CGSize {
        let fixedWidth = max(self.frame.size.width, 20)
        let newSize = self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        return CGSize(width: fixedWidth, height: max(newSize.height + 2.5, Size.minTextViewHeight))
    }

    override func becomeFirstResponder() -> Bool {
        line.backgroundColor = selectedLineColor
        return super.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        line.backgroundColor = lineColor
        return super.resignFirstResponder()
    }

    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        if let font = font {
            rect.size.height = font.pointSize - font.descender
        }
        return rect
    }
}
