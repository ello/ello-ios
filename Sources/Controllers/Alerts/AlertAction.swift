////
///  AlertAction.swift
//

typealias AlertHandler = (AlertAction) -> Void
typealias AlertCellConfigClosure = (
    _ cell: AlertCell,
    _ action: AlertAction,
    _ textAlignment: NSTextAlignment
) -> Void

enum ActionStyle {
    case title
    case subtitle
    case message

    case white
    case light
    case dark
    case green
    case gray
    case okCancel
    case urlInput
}

struct AlertAction {
    let title: String
    let initial: String
    let style: ActionStyle
    let handler: AlertHandler?
    var waitForDismiss = false

    init(title: String = "", initial: String = "", style: ActionStyle, handler: AlertHandler? = nil) {
        self.title = title
        self.initial = initial
        self.style = style
        self.handler = handler
    }

    var isInput: Bool {
        switch style {
        case .urlInput, .okCancel:
            return true
        default:
            return false
        }
    }

    var isTappable: Bool {
        switch style {
        case .title, .subtitle, .message:
            return false
        default:
            return true
        }
    }

    func heightForWidth(_ tableWidth: CGFloat) -> CGFloat {
        switch style {
        case .title:
            return 25
        case .subtitle:
            return 25
        case .message:
            let width = tableWidth - 40
            let attributedString = NSAttributedString(label: title, style: .black)
            let height = attributedString.heightForWidth(width) + 20
            return height
        default:
            return 60
        }
    }

    var configure: AlertCellConfigClosure {
        switch style {
        case .title:
            return AlertCellPresenter.configureForTitle
        case .subtitle:
            return AlertCellPresenter.configureForSubtitle
        case .message:
            return AlertCellPresenter.configureForMessage
        case .white:
            return AlertCellPresenter.configureForWhiteAction
        case .light:
            return AlertCellPresenter.configureForLightAction
        case .dark:
            return AlertCellPresenter.configureForDarkAction
        case .green:
            return AlertCellPresenter.configureForGreenAction
        case .gray:
            return AlertCellPresenter.configureForGrayAction
        case .okCancel:
            return AlertCellPresenter.configureForOKCancelAction
        case .urlInput:
            return AlertCellPresenter.configureForURLAction
        }
    }

}
