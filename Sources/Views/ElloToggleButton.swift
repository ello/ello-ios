////
///  ElloToggleButton.swift
//

class ElloToggleButton: UIButton {
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
        let string = NSAttributedString(string: text, attributes: [
            .font: UIFont.defaultFont(),
            .foregroundColor: color,
            ])
        setAttributedTitle(string, for: .normal)
    }

    private func toggleButton() {
        let highlightedColor: UIColor = isEnabled ? .greyA : .greyC
        let offColor: UIColor = .white

        layer.borderColor = highlightedColor.cgColor
        backgroundColor = value ? highlightedColor : offColor
        let text = self.text ?? (value ? "Yes" : "No")
        setText(text, color: value ? offColor : highlightedColor)
    }
}
