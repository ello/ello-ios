////
///  AlertCellPresenter.swift
//

struct AlertCellPresenter {

    static func configureCell(_ cell: AlertCell) {
        cell.backgroundColor = .white
        cell.contentView.backgroundColor = .white

        cell.background.layer.borderColor = nil
        cell.background.layer.masksToBounds = true
        cell.background.layer.cornerRadius = 5

        cell.label.text = ""
        cell.label.font = .defaultFont()
        cell.label.isHidden = true

        cell.button.text = ""
        cell.button.font = .defaultFont()
        cell.button.isVisible = true

        cell.input.isHidden = true
        cell.okButton.isHidden = true
        cell.cancelButton.isHidden = true
    }

    static func configureForTitle(
        _ cell: AlertCell,
        action: AlertAction,
        textAlignment: NSTextAlignment
    ) {
        configureCell(cell)

        cell.button.isHidden = true

        cell.label.isVisible = true
        cell.label.font = .regularBlackFont(18)
        cell.label.text = action.title
        cell.label.textColor = .black
        cell.label.textAlignment = .left
        cell.background.backgroundColor = .white
    }

    static func configureForSubtitle(
        _ cell: AlertCell,
        action: AlertAction,
        textAlignment: NSTextAlignment
    ) {
        configureCell(cell)

        cell.button.isHidden = true

        cell.label.isVisible = true
        cell.label.text = action.title
        cell.label.textColor = .greyA
        cell.label.textAlignment = .left
        cell.background.backgroundColor = .white
    }

    static func configureForMessage(
        _ cell: AlertCell,
        action: AlertAction,
        textAlignment: NSTextAlignment
    ) {
        configureCell(cell)

        cell.button.isHidden = true

        cell.label.isVisible = true
        let attributedString = NSAttributedString(action.title)
        cell.label.attributedText = attributedString
        cell.background.backgroundColor = .white
    }

    static func configureForWhiteAction(
        _ cell: AlertCell,
        action: AlertAction,
        textAlignment: NSTextAlignment
    ) {
        configureCell(cell)

        cell.button.text = action.title
        cell.button.textColor = .black
        cell.button.textAlignment = textAlignment
        cell.background.backgroundColor = .white
    }

    static func configureForLightAction(
        _ cell: AlertCell,
        action: AlertAction,
        textAlignment: NSTextAlignment
    ) {
        configureCell(cell)

        cell.button.text = action.title
        cell.button.textColor = .grey6
        cell.button.textAlignment = textAlignment
        cell.background.backgroundColor = .greyE5
    }

    static func configureForDarkAction(
        _ cell: AlertCell,
        action: AlertAction,
        textAlignment: NSTextAlignment
    ) {
        configureCell(cell)

        cell.button.text = action.title
        cell.button.textColor = .white
        cell.button.textAlignment = textAlignment
        cell.background.backgroundColor = .black
    }

    static func configureForGreenAction(
        _ cell: AlertCell,
        action: AlertAction,
        textAlignment: NSTextAlignment
    ) {
        configureCell(cell)

        cell.button.text = action.title
        cell.button.textColor = .white
        cell.button.textAlignment = textAlignment
        cell.background.backgroundColor = .greenD1
    }

    static func configureForGrayAction(
        _ cell: AlertCell,
        action: AlertAction,
        textAlignment: NSTextAlignment
    ) {
        configureCell(cell)

        cell.button.text = action.title
        cell.button.textColor = .grey6
        cell.button.textAlignment = textAlignment
        cell.background.backgroundColor = .greyE5
    }

    static func configureForInputAction(_ cell: AlertCell, action: AlertAction) {
        configureCell(cell)

        cell.label.isHidden = true
        cell.button.isHidden = true

        cell.input.isVisible = true
        cell.input.placeholder = action.title
        cell.input.keyboardAppearance = .dark
        cell.input.keyboardType = .default
        cell.input.autocapitalizationType = .sentences
        cell.input.autocorrectionType = .default
        cell.input.spellCheckingType = .default
        cell.input.enablesReturnKeyAutomatically = true
        cell.input.returnKeyType = .default

        cell.background.backgroundColor = .white
    }

    static func configureForURLAction(
        _ cell: AlertCell,
        action: AlertAction,
        textAlignment: NSTextAlignment
    ) {
        configureForInputAction(cell, action: action)

        cell.input.keyboardType = .URL
        cell.input.autocapitalizationType = .none
        cell.input.autocorrectionType = .no
        cell.input.spellCheckingType = .no
    }

    static func configureForOKCancelAction(
        _ cell: AlertCell,
        action: AlertAction,
        textAlignment: NSTextAlignment
    ) {
        configureCell(cell)

        cell.background.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear

        cell.label.isHidden = true
        cell.button.isHidden = true
        cell.input.isHidden = true
        cell.okButton.isVisible = true
        cell.cancelButton.isVisible = true
    }

}
