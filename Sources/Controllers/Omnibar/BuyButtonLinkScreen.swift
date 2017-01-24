////
///  BuyButtonLinkScreen.swift
//

import SnapKit

protocol BuyButtonLinkDelegate: class {
    func closeModal()
    func submitLink(_ url: URL)
    func clearLink()
}

class BuyButtonLinkScreen: UIView {
    struct Size {
        static let topMargin: CGFloat = 120
        static let sideMargin: CGFloat = 10
        static let textFieldOffset: CGFloat = 40
        static let textFieldHeight: CGFloat = 60
        static let buttonHeight: CGFloat = 60
        static let cancelOffset: CGFloat = 25
    }

    let backgroundButton = UIButton()
    let titleLabel = UILabel()
    let productLinkField = ElloTextField()
    let submitButton = StyledButton(style: .Green)
    let removeButton = StyledButton(style: .Green)
    let cancelLabel = UILabel()

    var submitButtonTrailingRight: Constraint!
    var submitButtonTrailingRemove: Constraint!

    weak var delegate: BuyButtonLinkDelegate?

    var buyButtonURL: URL? {
        get { return URL(string: productLinkField.text ?? "") }
        set {
            if let buyButtonURL = newValue {
                productLinkField.text = buyButtonURL.absoluteString
                submitButtonTrailingRight.deactivate()
                submitButtonTrailingRemove.activate()
                removeButton.isHidden = false
            }
            else {
                productLinkField.text = ""
                submitButtonTrailingRight.activate()
                submitButtonTrailingRemove.deactivate()
                removeButton.isHidden = true
            }
            productLinkDidChange()
        }
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)

        style()
        bindActions()
        setText()
        arrange()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func style() {
        backgroundButton.backgroundColor = .modalBackground()

        titleLabel.font = .defaultFont(18)
        titleLabel.textColor = .white

        cancelLabel.font = .defaultFont()
        cancelLabel.textColor = .greyA()

        productLinkField.backgroundColor = .white
        productLinkField.keyboardType = .URL
        productLinkField.autocapitalizationType = .none
        productLinkField.autocorrectionType = .no
        productLinkField.spellCheckingType = .no
        productLinkField.keyboardAppearance = .dark
        productLinkField.enablesReturnKeyAutomatically = true
        productLinkField.returnKeyType = .default

        submitButton.isEnabled = false
        removeButton.isHidden = true
    }

    fileprivate func bindActions() {
        backgroundButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitLink), for: .touchUpInside)
        removeButton.addTarget(self, action: #selector(removeLink), for: .touchUpInside)
        productLinkField.addTarget(self, action: #selector(productLinkDidChange), for: .editingChanged)
    }

    fileprivate func setText() {
        titleLabel.text = InterfaceString.Omnibar.SellYourWorkTitle
        productLinkField.placeholder = InterfaceString.Omnibar.ProductLinkPlaceholder
        submitButton.setTitle(InterfaceString.Submit, for: .normal)
        removeButton.setTitle(InterfaceString.Remove, for: .normal)
        cancelLabel.text = InterfaceString.Cancel
    }

    fileprivate func arrange() {
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
            submitButtonTrailingRight = make.trailing.equalTo(self).offset(-Size.sideMargin).constraint
            submitButtonTrailingRemove = make.trailing.equalTo(removeButton.snp.leading).offset(-Size.sideMargin).constraint
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

    func productLinkDidChange() {
        if let url = productLinkField.text {
            submitButton.isEnabled = URL.isValidShorthand(url)
        }
        else {
            submitButton.isEnabled = false
        }
    }

    func closeModal() {
        delegate?.closeModal()
    }

    func submitLink() {
        guard let urlString = productLinkField.text else {
            return
        }

        if let url = URL.shorthand(urlString) {
            delegate?.submitLink(url)
        }
        closeModal()
    }

    func removeLink() {
        delegate?.clearLink()
        closeModal()
    }
}
