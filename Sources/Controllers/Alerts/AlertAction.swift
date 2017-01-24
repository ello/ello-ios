////
///  AlertAction.swift
//

import UIKit

typealias AlertHandler = ((AlertAction) -> Void)?
typealias AlertCellConfigClosure = (
    _ cell: AlertCell,
    _ type: AlertType,
    _ action: AlertAction,
    _ textAlignment: NSTextAlignment
) -> Void

enum ActionStyle {
    case white
    case light
    case dark
    case green
    case roundedGrayFill
    case okCancel
    case urlInput
}

struct AlertAction {
    let title: String
    let style: ActionStyle
    let handler: AlertHandler

    var isInput: Bool {
        switch style {
        case .urlInput, .okCancel:
            return true
        default:
            return false
        }
    }

    init(title: String, style: ActionStyle, handler: AlertHandler = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }

    var configure: AlertCellConfigClosure {
        switch style {
        case .white:
            return AlertCellPresenter.configureForWhiteAction
        case .light:
            return AlertCellPresenter.configureForLightAction
        case .dark:
            return AlertCellPresenter.configureForDarkAction
        case .green:
            return AlertCellPresenter.configureForGreenAction
        case .roundedGrayFill:
            return AlertCellPresenter.configureForRoundedGrayFillAction
        case .okCancel:
            return AlertCellPresenter.configureForOKCancelAction
        case .urlInput:
            return AlertCellPresenter.configureForURLAction
        }
    }

}
