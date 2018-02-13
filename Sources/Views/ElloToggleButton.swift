////
///  ElloToggleButton.swift
//

class ElloToggleButton: Button {
    var text: String? { didSet { updateButton() }}
    var value: Bool = false { didSet { updateButton() }}

    override var intrinsicContentSize: CGSize { return CGSize(width: 40, height: 30) }
    override var isEnabled: Bool {
        didSet {
            updateButton()
        }
    }

    override func style() {
        layer.borderWidth = 1
        updateButton()
    }

    func setText(_ text: String, color: UIColor) {
        let string = NSAttributedString(string: text, attributes: [
            .font: UIFont.defaultFont(),
            .foregroundColor: color,
            ])
        setAttributedTitle(string, for: .normal)
    }

    private func updateButton() {
        let highlightedColor: UIColor = isEnabled ? .greyA : .greyC
        let offColor: UIColor = .white

        layer.borderColor = highlightedColor.cgColor
        backgroundColor = value ? highlightedColor : offColor
        let text = self.text ?? (value ? "Yes" : "No")
        setText(text, color: value ? offColor : highlightedColor)
    }
}
