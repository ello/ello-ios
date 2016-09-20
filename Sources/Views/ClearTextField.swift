////
///  ClearTextField.swift
//

public class ClearTextField: UITextField {
    struct Size {
        static let lineMargin: CGFloat = 5
    }

    public let onePasswordButton = OnePasswordButton()
    public var lineColor: UIColor? = .grey6() {
        didSet {
            if !isFirstResponder() {
                line.backgroundColor = lineColor
            }
        }
    }
    public var selectedLineColor: UIColor? = .whiteColor() {
        didSet {
            if isFirstResponder() {
                line.backgroundColor = selectedLineColor
            }
        }
    }
    private var line = UIView()
    public var hasOnePassword = false {
        didSet {
            onePasswordButton.hidden = !hasOnePassword
            setNeedsLayout()
        }
    }
    public var validationState: ValidationState = .None {
        didSet {
            rightView = UIImageView(image: validationState.imageRepresentation)
            // This nonsense below is to prevent the rightView
            // from animating into position from 0,0 and passing specs
            rightView?.frame = rightViewRectForBounds(self.bounds)
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        sharedSetup()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedSetup()
    }

    func sharedSetup() {
        backgroundColor = .clearColor()
        font = .defaultFont(18)
        textColor = .whiteColor()
        rightViewMode = .Always

        addSubview(onePasswordButton)
        onePasswordButton.hidden = !hasOnePassword
        onePasswordButton.snp_makeConstraints { make in
            make.centerY.equalTo(self).offset(-Size.lineMargin / 2)
            make.trailing.equalTo(self)
            make.size.equalTo(CGSize.minButton)
        }

        addSubview(line)
        line.backgroundColor = lineColor
        line.snp_makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self)
            make.height.equalTo(1)
        }
    }

    override public func intrinsicContentSize() -> CGSize {
        var size = super.intrinsicContentSize()
        if size.height != UIViewNoIntrinsicMetric {
            size.height += Size.lineMargin
        }
        return size
    }

    override public func drawPlaceholderInRect(rect: CGRect) {
        placeholder?.drawInRect(rect, withAttributes: [
            NSFontAttributeName: UIFont.defaultFont(18),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
        ])
    }

    override public func becomeFirstResponder() -> Bool {
        line.backgroundColor = selectedLineColor
        return super.becomeFirstResponder()
    }

    override public func resignFirstResponder() -> Bool {
        line.backgroundColor = lineColor
        return super.resignFirstResponder()
    }

// MARK: Layout rects

    override public func textRectForBounds(bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }

    override public func editingRectForBounds(bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }

    override public func clearButtonRectForBounds(bounds: CGRect) -> CGRect {
        var rect = super.clearButtonRectForBounds(bounds)
        rect.origin.x -= 10
        if hasOnePassword {
            rect.origin.x -= 44
        }
        return rect
    }

    override public func rightViewRectForBounds(bounds: CGRect) -> CGRect {
        var rect = super.rightViewRectForBounds(bounds)
        rect.origin.x -= 10
        if hasOnePassword {
            rect.origin.x -= 20
        }
        return rect
    }

    private func rectForBounds(bounds: CGRect) -> CGRect {
        var rect = bounds.shrinkLeft(15)
        if validationState.imageRepresentation != nil {
            rect = rect.shrinkLeft(20)
        }
        return rect
    }

}
