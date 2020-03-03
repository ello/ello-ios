////
///  BuyButtonLinkScreen.swift
//

import SnapKit

class BuyButtonLinkScreen: View, BuyButtonLinkScreenProtocol {
    struct Size {
        static let topMargin: CGFloat = 120
        static let sideMargin: CGFloat = 10
        static let textFieldOffset: CGFloat = 40
        static let textFieldHeight: CGFloat = 60
        static let buttonHeight: CGFloat = 60
        static let cancelOffset: CGFloat = 25
    }

    private let backgroundButton = UIButton()
    private let titleLabel = UILabel()
    private let productLinkField = ElloTextField()
    private let submitButton = StyledButton(style: .green)
    private let removeButton = StyledButton(style: .green)
    private let cancelLabel = UILabel()
    private var submitButtonTrailingRight: Constraint!
    private var submitButtonTrailingRemove: Constraint!

    weak var delegate: BuyButtonLinkScreenDelegate?

    var buyButtonURL: URL? {
        get { return URL(string: productLinkField.text ?? "") }
        set {
            let hasLink = newValue != nil
            submitButtonTrailingRemove.set(isActivated: hasLink)
            submitButtonTrailingRight.set(isActivated: !hasLink)
            removeButton.isVisible = hasLink
            productLinkField.text = newValue?.absoluteString
            productLinkDidChange()
        }
    }

    override func setup() {
        submitButton.isEnabled = false
        removeButton.isHidden = true
    }

    override func style() {
        backgroundButton.backgroundColor = .dimmedModalBackground

        titleLabel.font = .defaultFont(18)
        titleLabel.textColor = .white

        cancelLabel.font = .defaultFont()
        cancelLabel.textColor = .greyA

        productLinkField.backgroundColor = .white
        productLinkField.keyboardType = .URL
        productLinkField.autocapitalizationType = .none
        productLinkField.autocorrectionType = .no
        productLinkField.spellCheckingType = .no
        productLinkField.keyboardAppearance = .dark
        productLinkField.enablesReturnKeyAutomatically = true
        productLinkField.returnKeyType = .default
    }

    override func bindActions() {
        backgroundButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitLink), for: .touchUpInside)
        removeButton.addTarget(self, action: #selector(removeLink), for: .touchUpInside)
        productLinkField.addTarget(
            self,
            action: #selector(productLinkDidChange),
            for: .editingChanged
        )
    }

    override func setText() {
        titleLabel.text = InterfaceString.Omnibar.SellYourWorkTitle
        productLinkField.placeholder = InterfaceString.Omnibar.ProductLinkPlaceholder
        submitButton.title = InterfaceString.Submit
        removeButton.title = InterfaceString.Remove
        cancelLabel.text = InterfaceString.Cancel
    }

    override func arrange() {
        addSubview(backgroundButton)
        addSubview(titleLabel)
        addSubview(productLinkField)
        addSubview(submitButton)
        addSubview(removeButton)
        addSubview(cancelLabel)

        backgroundButton.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self).offset(Size.topMargin)
            make.leading.equalTo(self).offset(Size.sideMargin)
        }

        productLinkField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Size.textFieldOffset)
            make.leading.equalTo(self).offset(Size.sideMargin)
            make.trailing.equalTo(self).offset(-Size.sideMargin)
            make.height.equalTo(Size.textFieldHeight)
        }

        submitButton.snp.makeConstraints { make in
            make.top.equalTo(productLinkField.snp.bottom).offset(Size.sideMargin)
            make.leading.equalTo(self).offset(Size.sideMargin)
            submitButtonTrailingRight =
                make.trailing.equalTo(self).offset(-Size.sideMargin).constraint
            submitButtonTrailingRemove =
                make.trailing.equalTo(removeButton.snp.leading).offset(-Size.sideMargin).constraint
            make.height.equalTo(Size.buttonHeight)
        }
        submitButtonTrailingRemove.deactivate()

        removeButton.snp.makeConstraints { make in
            make.top.equalTo(productLinkField.snp.bottom).offset(Size.sideMargin)
            make.width.equalTo(self).dividedBy(2).offset(-2 * Size.sideMargin)
            make.trailing.equalTo(self).offset(-Size.sideMargin)
            make.height.equalTo(Size.buttonHeight)
        }

        cancelLabel.snp.makeConstraints { make in
            make.top.equalTo(submitButton.snp.bottom).offset(Size.cancelOffset)
            make.leading.equalTo(self).offset(Size.sideMargin)
        }
    }

    @objc
    func productLinkDidChange() {
        if let url = productLinkField.text {
            submitButton.isEnabled = URL.isValidShorthand(url)
        }
        else {
            submitButton.isEnabled = false
        }
    }

    @objc
    func closeModal() {
        delegate?.closeModal()
    }

    @objc
    func submitLink() {
        guard let urlString = productLinkField.text else {
            return
        }

        if let url = URL.shorthand(urlString) {
            delegate?.submitLink(url)
        }
        closeModal()
    }

    @objc
    func removeLink() {
        delegate?.clearLink()
        closeModal()
    }
}
