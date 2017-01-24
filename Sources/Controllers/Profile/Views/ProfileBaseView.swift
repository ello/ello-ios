////
///  ProfileBaseView.swift
//

class ProfileBaseView: UIView {
    struct Size {
        static let grayInset: CGFloat = 15
    }

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        privateInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func privateInit() {
        style()
        bindActions()
        setText()
        arrange()

        // for controllers that use "container" views, they need to be set to the correct dimensions,
        // otherwise there'll be constraint violations.
        layoutIfNeeded()
    }
}

extension ProfileBaseView {

    func style() {}

    func bindActions() {}

    func setText() {}

    func arrange() {}
}
