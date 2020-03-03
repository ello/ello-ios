////
///  SearchTextField.swift
//

class SearchTextField: UITextField {
    override var placeholder: String? {
        didSet {
            if let placeholder = placeholder {
                attributedPlaceholder = NSAttributedString(
                    string: placeholder,
                    attributes: [
                        .foregroundColor: UIColor.greyA
                    ]
                )
            }
        }
    }
    private var line = Line(color: .greyA)

    override required init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    private func sharedInit() {
        clearButtonMode = .whileEditing
        font = .defaultFont(18)
        textColor = .black
        autocapitalizationType = .none
        autocorrectionType = .no
        spellCheckingType = .no
        enablesReturnKeyAutomatically = true
        returnKeyType = .search
        keyboardAppearance = .dark
        keyboardType = .default
        leftViewMode = .always
        leftView = UIImageView(image: InterfaceImage.search.normalImage)

        addSubview(line)
        line.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.bottom.equalTo(self).offset(-10)
        }
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }

    private func rectForBounds(_ bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.shrink(right: 10)
    }
}
