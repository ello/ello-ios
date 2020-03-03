////
///  View.swift
//

class View: UIView {
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        style()
        bindActions()
        setText()
        arrange()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        style()
        bindActions()
        setText()
        arrange()
    }

    convenience init() {
        self.init(frame: .zero)
    }

    override func traitCollectionDidChange(_ prev: UITraitCollection?) {
        super.traitCollectionDidChange(prev)
        style()
    }

    func setup() {}
    func style() {}
    func bindActions() {}
    func setText() {}
    func arrange() {}
}

class Container: UIView {}
class Spacer: UIView {}
