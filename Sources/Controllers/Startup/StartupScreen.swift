////
///  StartupScreen.swift
//

import SnapKit


class StartupScreen: EmptyScreen {
    struct Size {
        static let topLogoOffset: CGFloat = 100
        static let bottomLogoOffset: CGFloat = 90
        static let logoSize: CGFloat = 250
        static let buttonInset: CGFloat = 10
        static let buttonHeight: CGFloat = 50
        static let maxButtonWidth: CGFloat = 414 - 2 * buttonInset
    }

    weak var delegate: StartupDelegate?

    let logoImage = FLAnimatedImageView()
    let signUpButton = StyledButton(style: .Green)
    let loginButton = StyledButton(style: .RoundedGray)

    override func setText() {
        if let resource = Bundle.main.path(forResource: "ello-crazy-logo", ofType: "gif") {
            let data = try? Data(contentsOf: URL(fileURLWithPath: resource))
            let image = FLAnimatedImage(animatedGIFData: data)
            logoImage.animatedImage = image
        }
        signUpButton.setTitle(InterfaceString.Startup.SignUp, for: .normal)
        loginButton.setTitle(InterfaceString.Startup.Login, for: .normal)
    }

    override func bindActions() {
        signUpButton.addTarget(self, action: #selector(signUpAction), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
    }

    override func arrange() {
        super.arrange()

        addSubview(logoImage)
        addSubview(signUpButton)
        addSubview(loginButton)

        logoImage.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(blackBar.snp.bottom).offset(Size.topLogoOffset).priority(Priority.medium)
            make.size.equalTo(CGSize(width: Size.logoSize, height: Size.logoSize))
            make.top.greaterThanOrEqualTo(blackBar.snp.bottom).priority(Priority.required)
            make.bottom.lessThanOrEqualTo(signUpButton.snp.top).offset(-Size.bottomLogoOffset).priority(Priority.required)
        }

        loginButton.snp.makeConstraints { make in
            make.bottom.equalTo(self).offset(-Size.buttonInset)
            make.centerX.equalTo(self)
            make.height.equalTo(Size.buttonHeight)
            make.width.equalTo(self).offset(-2 * Size.buttonInset).priority(Priority.medium)
            make.width.lessThanOrEqualTo(Size.maxButtonWidth).priority(Priority.required)
        }

        signUpButton.snp.makeConstraints { make in
            make.centerX.width.height.equalTo(loginButton)
            make.bottom.equalTo(loginButton.snp.top).offset(-Size.buttonInset)
        }
    }
}

extension StartupScreen {
    @objc func signUpAction() {
        delegate?.signUpAction()
    }

    @objc func loginAction() {
        delegate?.loginAction()
    }
}

extension StartupScreen: StartupScreenProtocol {
}
