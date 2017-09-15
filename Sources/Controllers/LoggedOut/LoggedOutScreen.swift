////
///  LoggedOutScreen.swift
//

import SnapKit


class LoggedOutScreen: Screen, LoggedOutScreenProtocol {
    struct Size {
        static let bottomBarHeight: CGFloat = calculateHeight()
        static let buttonInsets = calculateInsets()
        static let buttonSpacing: CGFloat = 10
        static let loginButtonWidth: CGFloat = 75
        static let closeButtonOffset = CGPoint(x: 6, y: -5)
        static let textMargin: CGFloat = 20

        static private func calculateHeight() -> CGFloat {
            return 60 + AppSetup.shared.bestBottomMargin
        }
        static private func calculateInsets() -> UIEdgeInsets {
            var insets = UIEdgeInsets(all: 10)
            insets.bottom = AppSetup.shared.bestBottomMargin
            return insets
        }
    }

    let controllerView = UIView()
    let bottomBarView = UIView()
    let bottomBarExtraMargin = UIView()
    let joinButton = StyledButton(style: .green)
    let loginButton = StyledButton(style: .clearGray)
    let closeButton = UIButton()
    let joinLabel = StyledLabel(style: .large)
    let tagLabel = StyledLabel(style: .black)
    weak var delegate: LoggedOutProtocol?
    fileprivate let debouncedHideText = debounce(5)

    var bottomBarCollapsedConstraint: Constraint!
    var bottomBarExpandedConstraint: Constraint!

    var bottomBarHeight: CGFloat {
        if bottomBarView.frame.minY < frame.height {
            return Size.bottomBarHeight
        }
        return 0
    }

    func setControllerView(_ childView: UIView) {
        for view in controllerView.subviews {
            view.removeFromSuperview()
        }

        controllerView.addSubview(childView)
    }

    override func setText() {
        joinLabel.text = InterfaceString.Startup.Join
        tagLabel.text = InterfaceString.Startup.Tagline
    }

    override func bindActions() {
        joinButton.addTarget(self, action: #selector(joinAction), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(hideJoinText), for: .touchUpInside)
    }

    override func style() {
        closeButton.setImages(.x)
        tagLabel.isMultiline = true
        bottomBarView.backgroundColor = .greyEF
        bottomBarView.clipsToBounds = true
        joinButton.setTitle(InterfaceString.Startup.SignUp, for: .normal)
        loginButton.setTitle(InterfaceString.Startup.Login, for: .normal)
    }

    override func arrange() {
        addSubview(controllerView)
        addSubview(bottomBarView)
        bottomBarView.addSubview(loginButton)
        bottomBarView.addSubview(joinLabel)
        bottomBarView.addSubview(tagLabel)
        bottomBarView.addSubview(joinButton)
        bottomBarView.addSubview(closeButton)

        controllerView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        bottomBarView.snp.makeConstraints { make in
            make.trailing.leading.bottom.equalTo(self)
            bottomBarCollapsedConstraint = make.height.equalTo(Size.bottomBarHeight).constraint
            bottomBarExpandedConstraint = make.top.equalTo(joinLabel.snp.top).offset(-Size.textMargin).constraint
        }
        bottomBarExpandedConstraint.deactivate()

        tagLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(bottomBarView).inset(Size.buttonInsets)
            make.bottom.equalTo(joinButton.snp.top).offset(-Size.textMargin)
        }

        joinLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(bottomBarView).inset(Size.buttonInsets)
            make.bottom.equalTo(tagLabel.snp.top).offset(-Size.textMargin)
        }

        joinButton.snp.makeConstraints { make in
            make.leading.bottom.equalTo(bottomBarView).inset(Size.buttonInsets)
            make.height.equalTo(Size.bottomBarHeight - Size.buttonInsets.top - Size.buttonInsets.bottom)
        }

        loginButton.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(bottomBarView).inset(Size.buttonInsets)
            make.height.equalTo(Size.bottomBarHeight - Size.buttonInsets.top - Size.buttonInsets.bottom)
            make.leading.equalTo(joinButton.snp.trailing).offset(Size.buttonSpacing)
            make.width.equalTo(Size.loginButtonWidth)
        }

        closeButton.snp.makeConstraints { make in
            make.trailing.equalTo(bottomBarView).inset(Size.buttonInsets.right + Size.closeButtonOffset.x)
            make.top.equalTo(joinLabel).offset(Size.closeButtonOffset.y)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        for childView in controllerView.subviews {
            childView.frame = controllerView.bounds
        }
    }
}

extension LoggedOutScreen {
    func showJoinText() {
        bottomBarCollapsedConstraint.deactivate()
        bottomBarExpandedConstraint.activate()
        let height = Size.textMargin + joinLabel.frame.height + Size.textMargin + tagLabel.frame.height + Size.textMargin + joinButton.frame.height + Size.buttonInsets.bottom
        animate {
            self.bottomBarView.frame = self.bounds.fromBottom().grow(up: height)
            self.joinLabel.frame.origin.y = Size.textMargin
            self.tagLabel.frame.origin.y = self.joinLabel.frame.maxY + Size.textMargin
            self.joinButton.frame.origin.y = self.tagLabel.frame.maxY + Size.textMargin
            self.loginButton.frame.origin.y = self.tagLabel.frame.maxY + Size.textMargin
            self.closeButton.frame.origin.y = self.joinLabel.frame.y + Size.closeButtonOffset.y
        }
        debouncedHideText { [weak self] in self?.hideJoinText() }
    }

    @objc
    func joinAction() {
        delegate?.showJoinScreen()
    }

    @objc
    func loginAction() {
        delegate?.showLoginScreen()
    }

    @objc
    func hideJoinText() {
        bottomBarCollapsedConstraint.activate()
        bottomBarExpandedConstraint.deactivate()
        animate {
            self.layoutIfNeeded()
        }
    }
}
