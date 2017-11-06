////
///  ClearTextField.swift
//

class ClearTextField: UITextField {
    struct Size {
        static let lineMargin: CGFloat = 5
    }

    let onePasswordButton = OnePasswordButton()
    var lineColor: UIColor? = .grey6 {
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
    private var line = UIView()
    var hasOnePassword = false {
        didSet {
            onePasswordButton.isHidden = !hasOnePassword
            setNeedsLayout()
        }
    }
    var validationState: ValidationState = .none {
        didSet {
            rightView = UIImageView(image: validationState.imageRepresentation)
            // This nonsense below is to prevent the rightView
            // from animating into position from 0,0 and passing specs
            rightView?.frame = rightViewRect(forBounds: self.bounds)
            setNeedsLayout()
            layoutIfNeeded()
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

    func sharedSetup() {
        backgroundColor = .clear
        font = .defaultFont(18)
        textColor = .white
        rightViewMode = .always

        addSubview(onePasswordButton)
        onePasswordButton.isHidden = !hasOnePassword
        onePasswordButton.snp.makeConstraints { make in
            make.centerY.equalTo(self).offset(-Size.lineMargin / 2)
            make.trailing.equalTo(self)
            make.size.equalTo(CGSize.minButton)
        }

        addSubview(line)
        line.backgroundColor = lineColor
        line.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self)
            make.height.equalTo(1)
        }
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        if size.height != UIViewNoIntrinsicMetric {
            size.height += Size.lineMargin
        }
        return size
    }

    override func drawPlaceholder(in rect: CGRect) {
        placeholder?.draw(in: rect, withAttributes: [
            .font: UIFont.defaultFont(18),
            .foregroundColor: UIColor.white,
        ])
    }

    override func becomeFirstResponder() -> Bool {
        line.backgroundColor = selectedLineColor
        return super.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        line.backgroundColor = lineColor
        return super.resignFirstResponder()
    }

// MARK: Layout rects

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }

    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.clearButtonRect(forBounds: bounds)
        rect.origin.x -= 10
        if hasOnePassword {
            rect.origin.x -= 44
        }
        return rect
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x -= 10
        if hasOnePassword {
            rect.origin.x -= 20
        }
        return rect
    }

    private func rectForBounds(_ bounds: CGRect) -> CGRect {
        var rect = bounds.shrink(left: 15)
        if validationState.imageRepresentation != nil {
            rect = rect.shrink(left: 20)
        }
        return rect
    }

}
