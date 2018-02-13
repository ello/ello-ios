////
///  CredentialsScreen.swift
//

import SnapKit


class CredentialsScreen: EmptyScreen {
    struct Size {
        static let backTopInset: CGFloat = 10
        static let titleTop: CGFloat = 110
        static let inset: CGFloat = 10
        static let buttonHeight: CGFloat = 50
        static let buttonInset: CGFloat = 10
    }

    let scrollView = UIScrollView()
    var scrollViewWidthConstraint: Constraint!
    let backButton = UIButton()
    let titleLabel = StyledLabel(style: .largeBoldWhite)
    let gradientLayer = StartupGradientLayer()
    let continueButton = StyledButton(style: .roundedGrayOutline)
    let continueBackground = UIView()

    override func updateConstraints() {
        super.updateConstraints()
        scrollViewWidthConstraint.update(offset: frame.size.width)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let maxDimension = max(layer.frame.size.width, layer.frame.size.height)
        let size = CGSize(width: maxDimension, height: maxDimension)
        gradientLayer.frame.size = size
        gradientLayer.position = layer.bounds.center
    }

    override func bindActions() {
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
    }

    override func style() {
        backButton.setImages(.backChevron, style: .white)
        backButton.contentMode = .center
        layer.masksToBounds = true
    }

    override func arrange() {
        layer.addSublayer(gradientLayer)

        super.arrange()

        addSubview(scrollView)
        addSubview(continueBackground)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(backButton)

        continueBackground.addSubview(continueButton)

        scrollView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(blackBar.snp.bottom)
            make.bottom.equalTo(continueBackground.snp.top)
        }

        let scrollViewAnchor = UIView()
        scrollView.addSubview(scrollViewAnchor)
        scrollViewAnchor.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(scrollView)
            scrollViewWidthConstraint = make.width.equalTo(frame.size.width).priority(Priority.required).constraint
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView).offset(Size.titleTop)
            make.leading.equalTo(scrollView).offset(Size.inset)
        }

        backButton.snp.makeConstraints { make in
            make.top.equalTo(scrollView).offset(Size.backTopInset)
            make.leading.equalTo(scrollView)
            make.size.equalTo(CGSize.minButton)
        }

        continueButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(Size.buttonInset)
            make.bottom.equalTo(keyboardAnchor.snp.top).offset(-Size.buttonInset)
            make.bottom.lessThanOrEqualTo(self).inset(Globals.bestBottomMargin)
            make.height.equalTo(Size.buttonHeight)
        }

        continueBackground.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self)
            make.top.equalTo(continueButton).offset(-Size.buttonInset)
        }
    }

    @objc
    func backAction() {
    }

    func styleContinueButton(allValid: Bool) {
        if allValid {
            continueButton.style = .green
        }
        else {
            continueButton.style = .roundedGrayOutline
        }
    }
}
