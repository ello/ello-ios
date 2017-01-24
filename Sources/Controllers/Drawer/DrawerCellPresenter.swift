////
///  DrawerCellPresenter.swift
//

struct DrawerCellPresenter {

    static func configure(_ cell: DrawerCell, item: DrawerItem) {
        switch item.type {
        case .version:
            cell.label.font = UIFont.defaultFont(12)
            cell.label.textColor = .greyA()
            cell.line.isHidden = true
        default:
            cell.label.font = UIFont.defaultFont()
            cell.label.textColor = .white
            cell.line.isHidden = false
        }

        cell.label.text = item.name
        cell.selectionStyle = .none
    }
}
