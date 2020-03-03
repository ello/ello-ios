////
///  OnboardingScreen.swift
//

class OnboardingScreen: EmptyScreen {
    struct Size {
        static let buttonHeight: CGFloat = 50
        static let buttonInset: CGFloat = 10
        static let abortButtonWidth: CGFloat = 70
    }
    var controllerContainer: UIView = Container()
    private var buttonContainer = Container()
    private var promptButton = StyledButton(style: .roundedGrayOutline)
    private var nextButton = StyledButton(style: .green)
    private var abortButton = StyledButton(style: .grayText)

    weak var delegate: OnboardingScreenDelegate?

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
        set { promptButton.title = newValue ?? InterfaceString.Onboard.CreateProfile }
    }

    override func setup() {
        abortButton.isHidden = true
        nextButton.isHidden = true
    }

    override func style() {
        buttonContainer.backgroundColor = .greyE5
    }

    override func bindActions() {
        promptButton.isEnabled = false
        promptButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        abortButton.addTarget(self, action: #selector(abortAction), for: .touchUpInside)
    }

    override func setText() {
        promptButton.title = ""
        nextButton.title = ""
        abortButton.title = InterfaceString.Onboard.ImDone
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
            make.top.equalTo(keyboardAnchor.snp.top).offset(
                -(2 * Size.buttonInset + Size.buttonHeight)
            )
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
            make.top.equalTo(statusBar.snp.bottom)
            make.bottom.equalTo(buttonContainer.snp.top)
        }
    }

    private func updateButtonVisibility() {
        if hasAbortButton && canGoNext {
            promptButton.isHidden = true
            nextButton.isVisible = true
            abortButton.isVisible = true
        }
        else {
            promptButton.isEnabled = canGoNext
            promptButton.style = canGoNext ? .green : .roundedGrayOutline
            promptButton.isVisible = true
            nextButton.isHidden = true
            abortButton.isHidden = true
        }
    }

    func styleFor(step: OnboardingStep) {
        let nextString: String
        switch step {
        case .creatorType: nextString = InterfaceString.Onboard.CreateAccount
        case .categories: nextString = InterfaceString.Onboard.CreateProfile
        case .createProfile: nextString = InterfaceString.Onboard.InvitePeople
        case .inviteFriends: nextString = InterfaceString.Join.Discover
        }

        promptButton.isVisible = true
        nextButton.isHidden = true
        abortButton.isHidden = true
        promptButton.title = nextString
        nextButton.title = nextString
    }
}

extension OnboardingScreen {
    @objc
    func nextAction() {
        delegate?.nextAction()
    }

    @objc
    func abortAction() {
        delegate?.abortAction()
    }
}

extension OnboardingScreen: OnboardingScreenProtocol {}
