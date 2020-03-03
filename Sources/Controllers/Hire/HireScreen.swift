////
///  HireScreen.swift
//

import SnapKit


class HireScreen: StreamableScreen {
    struct Size {
        static let keyboardButtonHeight: CGFloat = 44
        static let textViewTopMargin: CGFloat = 40
        static let textViewSideMargins: CGFloat = 15
        static let placeholderTopMargin: CGFloat = 8
        static let successLabelLeading: CGFloat = 55
        static let successImageLeading: CGFloat = 20
    }
    struct Specs {
        static let successButtonTag = 1
    }

    var recipient: String = "" {
        didSet {
            successLabel.text = "Email sent to \(recipient)"
        }
    }
    weak var delegate: HireScreenDelegate?

    private let successView = UIView()
    private let successLabel = UILabel()
    private let successImage = UIImageView()
    private let textView = UITextView()
    private let placeholder = UILabel()
    private let keyboardSubmitButton = StyledButton()
    private var keyboardBottomConstraint: Constraint!

    override func setup() {
        keyboardSubmitButton.isEnabled = false
        successView.alpha = 0
    }

    override func style() {
        textView.backgroundColor = .clear
        textView.tintColor = .black
        textView.textColor = .black
        textView.font = UIFont.editorFont()
        textView.textContainer.lineFragmentPadding = 0
        textView.showsHorizontalScrollIndicator = false
        textView.keyboardAppearance = .dark

        placeholder.text = InterfaceString.Omnibar.SayEllo
        placeholder.textColor = .greyC
        placeholder.font = UIFont.editorFont()

        keyboardSubmitButton.contentEdgeInsets.left = 10
        keyboardSubmitButton.imageEdgeInsets.right = 20

        successView.backgroundColor = .white
        successLabel.textColor = .black
        successLabel.font = UIFont.defaultFont(18)
        successImage.interfaceImage = .validationOK
    }

    override func setText() {
        keyboardSubmitButton.setImages(.mail, style: .white)
        keyboardSubmitButton.title = InterfaceString.Send
    }

    override func bindActions() {
        textView.delegate = self
        keyboardSubmitButton.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
    }

    override func arrange() {
        super.arrange()

        addSubview(textView)
        addSubview(placeholder)
        addSubview(keyboardSubmitButton)
        keyboardSubmitButton.tag = Specs.successButtonTag

        textView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(Size.textViewSideMargins)
            make.top.equalTo(navigationBar.snp.bottom).offset(Size.textViewTopMargin)
            make.bottom.equalTo(keyboardSubmitButton.snp.top)
        }

        placeholder.snp.makeConstraints { make in
            make.top.equalTo(textView).offset(Size.placeholderTopMargin)
            make.leading.equalTo(textView)
        }

        keyboardSubmitButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.height.equalTo(Size.keyboardButtonHeight)
            make.bottom.lessThanOrEqualTo(self).offset(-ElloTabBar.Size.height).priority(
                Priority.required
            )
            keyboardBottomConstraint = make.bottom.equalTo(self).priority(Priority.high).constraint
        }

        let window = UIApplication.shared.keyWindow!
        window.addSubview(successView)
        successView.addSubview(successLabel)
        successView.addSubview(successImage)

        successView.snp.makeConstraints { make in
            make.edges.equalTo(window)
        }
        successLabel.snp.makeConstraints { make in
            make.leading.equalTo(successView).offset(Size.successLabelLeading)
            make.centerY.equalTo(successView)
        }
        successImage.snp.makeConstraints { make in
            make.leading.equalTo(successView).offset(Size.successImageLeading)
            make.centerY.equalTo(successView)
        }
    }

    func toggleKeyboard(visible: Bool) {
        self.layoutIfNeeded()

        let bottomInset = Keyboard.shared.keyboardBottomInset(inView: self)
        keyboardBottomConstraint.update(offset: -bottomInset)
        animateWithKeyboard {
            self.keyboardSubmitButton.frame.origin.y = self.frame.size.height - bottomInset
                - Size.keyboardButtonHeight
        }
    }

    @objc
    func submitAction() {
        guard let text = textView.text else { return }

        _ = textView.resignFirstResponder()
        self.delegate?.submit(body: text)
    }

    func showSuccess() {
        elloAnimate {
            self.successView.alpha = 1
        }
    }

    func hideSuccess() {
        elloAnimate {
            self.successView.alpha = 0
        }
    }

}

extension HireScreen: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let hasText = textView.text?.isEmpty != true
        placeholder.isHidden = hasText
        keyboardSubmitButton.isEnabled = hasText
        keyboardSubmitButton.backgroundColor = hasText ? .greenD1 : .black
    }
}

extension HireScreen: HireScreenProtocol {
}
