////
///  AlertCell.swift
//

import ElloUIFonts


@objc
protocol AlertCellResponder: class {
    func tappedOkButton()
    func tappedCancelButton()
}

class AlertCell: TableViewCell {
    static let reuseIdentifier = "AlertCell"

    struct Size {
        static let backgroundInsets = UIEdgeInsets(tops: 5, sides: 0)
        static let buttonSpacing: CGFloat = 10
        static let inputInsets = UIEdgeInsets(top: 0, left: 2, bottom: 8, right: 10)
        static let buttonInsets = UIEdgeInsets(tops: 0, sides: 18)
    }

    let background = UIView()
    let okButton = StyledButton(style: .roundedBlack)
    let cancelButton = StyledButton(style: .roundedBlack)
    let label = StyledLabel(style: .black)
    let button = UILabel()
    let input = ElloTextField()
    let inputBottomBorder = UIView()

    var onInputChanged: ((String) -> Void)?

    override func bindActions() {
        input.addTarget(self, action: #selector(didUpdateInput), for: .editingChanged)
        okButton.addTarget(self, action: #selector(didTapOkButton), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
    }

    override func setText() {
        okButton.title = InterfaceString.OK
        cancelButton.title = InterfaceString.Cancel
    }

    override func styleCell() {
        selectionStyle = .none
        label.textAlignment = .left
        label.isMultiline = true

        input.backgroundColor = .white
        input.font = .defaultFont()
        input.textColor = .black
        input.tintColor = .black
        input.clipsToBounds = false

        inputBottomBorder.backgroundColor = .black
    }

    override func arrange() {
        contentView.addSubview(background)
        background.addSubview(okButton)
        background.addSubview(cancelButton)

        contentView.addSubview(label)
        contentView.addSubview(button)
        contentView.addSubview(input)
        input.addSubview(inputBottomBorder)

        background.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(Size.backgroundInsets)
        }

        okButton.snp.makeConstraints { make in
            make.width.equalTo(cancelButton)
            make.leading.top.bottom.equalTo(background)
        }

        cancelButton.snp.makeConstraints { make in
            make.leading.equalTo(okButton.snp.trailing).offset(Size.buttonSpacing)
            make.trailing.top.bottom.equalTo(background)
        }

        label.snp.makeConstraints { make in
            make.leading.centerY.equalTo(contentView)
            make.trailing.lessThanOrEqualTo(contentView)
        }

        button.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(Size.buttonInsets).priority(Priority.required)
        }

        input.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(contentView).inset(Size.inputInsets)
        }

        inputBottomBorder.snp.makeConstraints { make in
            make.bottom.equalTo(input)
            make.leading.equalTo(input).offset(-10)
            make.trailing.equalTo(input).offset(10)
            make.height.equalTo(1)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        inputBottomBorder.frame = input.bounds.fromBottom().grow(top: 1, sides: 10, bottom: 0)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        label.text = ""
        label.textColor = .black
        label.textAlignment = .left
        input.text = ""
        if input.isFirstResponder {
            _ = input.resignFirstResponder()
        }
    }
}

extension AlertCell {

    @objc
    func didUpdateInput() {
        onInputChanged?(input.text ?? "")
    }

    @objc
    func didTapOkButton() {
        let responder: AlertCellResponder? = findResponder()
        responder?.tappedOkButton()
    }

    @objc
    func didTapCancelButton() {
        let responder: AlertCellResponder? = findResponder()
        responder?.tappedCancelButton()
    }

}
