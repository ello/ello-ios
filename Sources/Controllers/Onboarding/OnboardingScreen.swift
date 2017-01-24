////
///  OnboardingScreen.swift
//

class OnboardingScreen: EmptyScreen {
    struct Size {
        static let buttonHeight: CGFloat = 50
        static let buttonInset: CGFloat = 10
        static let abortButtonWidth: CGFloat = 70
    }
    var controllerContainer = UIView()
    fileprivate var buttonContainer = UIView()
    fileprivate var promptButton = StyledButton(style: .RoundedGray)
    fileprivate var nextButton = StyledButton(style: .Green)
    fileprivate var abortButton = StyledButton(style: .GrayText)

    weak var delegate: OnboardingDelegate?

    var hasAbortButton: Bool = false {
        didSet {
            updateButtonVisibility()
        }
    }
    var canGoNext: Bool = false {
        didSet {
            updateButtonVisibility()
        }
    }
    var prompt: String? {
        get { return promptButton.currentTitle }
        set { promptButton.setTitle(newValue ?? InterfaceString.Onboard.CreateProfile, for: .normal) }
    }

    override func style() {
        buttonContainer.backgroundColor = .greyE5()
        abortButton.isHidden = true
        nextButton.isHidden = true
    }

    override func bindActions() {
        promptButton.isEnabled = false
        promptButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        abortButton.addTarget(self, action: #selector(abortAction), for: .touchUpInside)
    }

    override func setText() {
        promptButton.setTitle(InterfaceString.Onboard.CreateProfile, for: .normal)
        nextButton.setTitle(InterfaceString.Onboard.CreateProfile, for: .normal)
        abortButton.setTitle(InterfaceString.Onboard.ImDone, for: .normal)
    }

    override func arrange() {
        super.arrange()

        addSubview(controllerContainer)
        addSubview(buttonContainer)
        buttonContainer.addSubview(promptButton)
        buttonContainer.addSubview(nextButton)
        buttonContainer.addSubview(abortButton)

        buttonContainer.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self)
            make.top.equalTo(keyboardAnchor.snp.top).offset(-(2 * Size.buttonInset + Size.buttonHeight))
        }

        promptButton.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(buttonContainer).inset(Size.buttonInset)
            make.height.equalTo(Size.buttonHeight)
        }

        nextButton.snp.makeConstraints { make in
            make.top.bottom.leading.equalTo(promptButton)
        }

        abortButton.snp.makeConstraints { make in
            make.top.bottom.trailing.equalTo(promptButton)
            make.leading.equalTo(nextButton.snp.trailing).offset(Size.buttonInset)
            make.width.equalTo(Size.abortButtonWidth)
        }

        controllerContainer.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(blackBar.snp.bottom)
            make.bottom.equalTo(buttonContainer.snp.top)
        }
    }

    fileprivate func updateButtonVisibility() {
        if hasAbortButton && canGoNext {
            promptButton.isHidden = true
            nextButton.isHidden = false
            abortButton.isHidden = false
        }
        else {
            promptButton.isEnabled = canGoNext
            promptButton.style = canGoNext ? .Green : .RoundedGray
            promptButton.isHidden = false
            nextButton.isHidden = true
            abortButton.isHidden = true
        }
    }

    func styleFor(step: OnboardingStep) {
        let nextString: String
        switch step {
        case .categories: nextString = InterfaceString.Onboard.CreateProfile
        case .createProfile: nextString = InterfaceString.Onboard.InvitePeople
        case .inviteFriends: nextString = InterfaceString.Join.Discover
        }

        promptButton.isHidden = false
        nextButton.isHidden = true
        abortButton.isHidden = true
        promptButton.setTitle(nextString, for: .normal)
        nextButton.setTitle(nextString, for: .normal)
    }
}

extension OnboardingScreen {
    func nextAction() {
        delegate?.nextAction()
    }

    func abortAction() {
        delegate?.abortAction()
    }
}

extension OnboardingScreen: OnboardingScreenProtocol {}
