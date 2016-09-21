////
///  OnboardingScreen.swift
//

public class OnboardingScreen: EmptyScreen {
    public struct Size {
        static let buttonHeight: CGFloat = 50
        static let buttonInset: CGFloat = 10
        static let abortButtonWidth: CGFloat = 70
    }
    public var controllerContainer = UIView()
    private var buttonContainer = UIView()
    private var promptButton = StyledButton(style: .RoundedGray)
    private var nextButton = StyledButton(style: .Green)
    private var abortButton = StyledButton(style: .GrayText)

    public weak var delegate: OnboardingDelegate?

    public var hasAbortButton: Bool = false {
        didSet {
            updateButtonVisibility()
        }
    }
    public var canGoNext: Bool = false {
        didSet {
            updateButtonVisibility()
        }
    }
    public var prompt: String? {
        get { return promptButton.currentTitle }
        set { promptButton.setTitle(newValue ?? InterfaceString.Onboard.CreateProfile, forState: .Normal) }
    }

    override func style() {
        buttonContainer.backgroundColor = .greyE5()
        abortButton.hidden = true
        nextButton.hidden = true
    }

    override func bindActions() {
        promptButton.enabled = false
        promptButton.addTarget(self, action: #selector(nextAction), forControlEvents: .TouchUpInside)
        nextButton.addTarget(self, action: #selector(nextAction), forControlEvents: .TouchUpInside)
        abortButton.addTarget(self, action: #selector(abortAction), forControlEvents: .TouchUpInside)
    }

    override func setText() {
        promptButton.setTitle(InterfaceString.Onboard.CreateProfile, forState: .Normal)
        nextButton.setTitle(InterfaceString.Onboard.CreateProfile, forState: .Normal)
        abortButton.setTitle(InterfaceString.Onboard.ImDone, forState: .Normal)
    }

    override func arrange() {
        super.arrange()

        addSubview(controllerContainer)
        addSubview(buttonContainer)
        buttonContainer.addSubview(promptButton)
        buttonContainer.addSubview(nextButton)
        buttonContainer.addSubview(abortButton)

        buttonContainer.snp_makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self)
            make.top.equalTo(keyboardAnchor.snp_top).offset(-(2 * Size.buttonInset + Size.buttonHeight))
        }

        promptButton.snp_makeConstraints { make in
            make.top.leading.trailing.equalTo(buttonContainer).inset(Size.buttonInset)
            make.height.equalTo(Size.buttonHeight)
        }

        nextButton.snp_makeConstraints { make in
            make.top.bottom.leading.equalTo(promptButton)
        }

        abortButton.snp_makeConstraints { make in
            make.top.bottom.trailing.equalTo(promptButton)
            make.leading.equalTo(nextButton.snp_trailing).offset(Size.buttonInset)
            make.width.equalTo(Size.abortButtonWidth)
        }

        controllerContainer.snp_makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(blackBar.snp_bottom)
            make.bottom.equalTo(buttonContainer.snp_top)
        }
    }

    private func updateButtonVisibility() {
        if hasAbortButton && canGoNext {
            promptButton.hidden = true
            nextButton.hidden = false
            abortButton.hidden = false
        }
        else {
            promptButton.enabled = canGoNext
            promptButton.style = canGoNext ? .Green : .RoundedGray
            promptButton.hidden = false
            nextButton.hidden = true
            abortButton.hidden = true
        }
    }

    public func styleFor(step step: OnboardingStep) {
        let nextString: String
        switch step {
        case .Categories: nextString = InterfaceString.Onboard.CreateProfile
        case .CreateProfile: nextString = InterfaceString.Onboard.InvitePeople
        case .InviteFriends: nextString = InterfaceString.Join.Discover
        }

        promptButton.hidden = false
        nextButton.hidden = true
        abortButton.hidden = true
        promptButton.setTitle(nextString, forState: .Normal)
        nextButton.setTitle(nextString, forState: .Normal)
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
