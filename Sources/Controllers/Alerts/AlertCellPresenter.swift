////
///  AlertCellPresenter.swift
//

import UIKit

struct AlertCellPresenter {

    static func configureCell(_ cell: AlertCell, type: AlertType = .normal) {
        cell.background.layer.borderColor = nil
        cell.background.layer.cornerRadius = 0
        cell.input.isHidden = true
        cell.okButton.isHidden = true
        cell.cancelButton.isHidden = true
        cell.contentView.backgroundColor = type.backgroundColor
    }

    static func configureForWhiteAction(_ cell: AlertCell, type: AlertType, action: AlertAction, textAlignment: NSTextAlignment) {
        configureCell(cell, type: type)

        cell.label.text = action.title
        cell.label.textColor = .black
        cell.label.textAlignment = textAlignment
        cell.background.backgroundColor = .white
    }

    static func configureForLightAction(_ cell: AlertCell, type: AlertType, action: AlertAction, textAlignment: NSTextAlignment) {
        configureCell(cell, type: type)

        cell.label.text = action.title
        cell.label.textColor = .grey6()
        cell.label.textAlignment = textAlignment
        cell.background.backgroundColor = .greyE5()
    }

    static func configureForDarkAction(_ cell: AlertCell, type: AlertType, action: AlertAction, textAlignment: NSTextAlignment) {
        configureCell(cell, type: type)

        cell.label.text = action.title
        cell.label.textColor = .white
        cell.label.textAlignment = textAlignment
        cell.background.backgroundColor = .black
    }

    static func configureForGreenAction(_ cell: AlertCell, type: AlertType, action: AlertAction, textAlignment: NSTextAlignment) {
        configureCell(cell, type: type)

        cell.label.text = action.title
        cell.label.textColor = .white
        cell.label.textAlignment = textAlignment
        cell.background.backgroundColor = .greenD1()
        cell.background.layer.cornerRadius = 5
    }

    static func configureForRoundedGrayFillAction(_ cell: AlertCell, type: AlertType, action: AlertAction, textAlignment: NSTextAlignment) {
        configureCell(cell, type: type)

        cell.label.text = action.title
        cell.label.textColor = .grey6()
        cell.label.textAlignment = textAlignment
        cell.background.backgroundColor = .greyE5()
        cell.background.layer.cornerRadius = 5
    }

    static func configureForInputAction(_ cell: AlertCell, type: AlertType, action: AlertAction) {
        configureCell(cell, type: type)

        cell.input.isHidden = false
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

    static func configureForURLAction(_ cell: AlertCell, type: AlertType, action: AlertAction, textAlignment: NSTextAlignment) {
        configureForInputAction(cell, type: type, action: action)

        cell.input.keyboardType = .URL
        cell.input.autocapitalizationType = .none
        cell.input.autocorrectionType = .no
        cell.input.spellCheckingType = .no
    }

    static func configureForOKCancelAction(_ cell: AlertCell, type: AlertType, action: AlertAction, textAlignment: NSTextAlignment) {
        cell.background.backgroundColor = .clear
        cell.label.isHidden = true
        cell.input.isHidden = true
        cell.okButton.isHidden = false
        cell.cancelButton.isHidden = false
    }

}
