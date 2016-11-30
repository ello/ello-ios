////
///  ElloTextField.swift
//

public class ElloTextField: UITextField {
    public var firstResponderDidChange: (Bool -> Void)?
    var hasOnePassword = false
    var validationState = ValidationState.None {
        didSet {
            self.rightViewMode = .Always
            self.rightView = UIImageView(image: validationState.imageRepresentation)
        }
    }

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedSetup()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedSetup()
    }

    func sharedSetup() {
        self.backgroundColor = UIColor.greyE5()
        self.font = UIFont.defaultFont()
        self.textColor = UIColor.blackColor()

        self.setNeedsDisplay()
    }

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
        return rect
    }

    private func rectForBounds(bounds: CGRect) -> CGRect {
        return bounds.shrinkLeft(15).inset(topBottom: 10, sides: 15)
    }

    override public func becomeFirstResponder() -> Bool {
        let val = super.becomeFirstResponder()
        firstResponderDidChange?(true)
        return val
    }

    override public func resignFirstResponder() -> Bool {
        let val = super.resignFirstResponder()
        firstResponderDidChange?(false)
        return val
    }

}
