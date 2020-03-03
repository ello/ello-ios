////
///  Control.swift
//

class Control: UIControl {
    required override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        bindActions()
        setText()
        arrange()
        layoutIfNeeded()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        style()
        bindActions()
        setText()
        arrange()
        layoutIfNeeded()
    }

    convenience init() {
        self.init(frame: .zero)
    }

    override func traitCollectionDidChange(_ prev: UITraitCollection?) {
        super.traitCollectionDidChange(prev)
        style()
    }

    func style() {}
    func bindActions() {}
    func setText() {}
    func arrange() {}
}
