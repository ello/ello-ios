////
///  ElloToggleButton.swift
//

class ElloToggleButton: UIButton {
    fileprivate let attributes = [NSFontAttributeName: UIFont.defaultFont()]

    var text: String? {
        didSet {
            toggleButton()
        }
    }
    var value: Bool = false {
        didSet {
            toggleButton()
        }
    }
    override var isEnabled: Bool {
        didSet {
            toggleButton()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 1

        toggleButton()
    }

    func setText(_ text: String, color: UIColor) {
        let string = NSMutableAttributedString(string: text, attributes: attributes)
        string.addAttribute(NSForegroundColorAttributeName, value: color, range: NSRange(location: 0, length: string.length))
        setAttributedTitle(string, for: .normal)
    }

    fileprivate func toggleButton() {
        let highlightedColor: UIColor = isEnabled ? .greyA() : .greyC()
        let offColor: UIColor = .white

        layer.borderColor = highlightedColor.cgColor
        backgroundColor = value ? highlightedColor : offColor
        let text = self.text ?? (value ? "Yes" : "No")
        setText(text, color: value ? offColor : highlightedColor)
    }
}
