////
///  AutoCompleteCellPresenter.swift
//

struct AutoCompleteCellPresenter {

    static func configure(_ cell: AutoCompleteCell, item: AutoCompleteItem) {
        cell.name.font = UIFont.defaultFont()
        cell.name.textColor = UIColor.white
        cell.line.isHidden = false
        cell.line.backgroundColor = UIColor.grey3()

        if let resultName = item.result.name {
            switch item.type {
            case .emoji:
                cell.name.text = ":\(resultName):"
            case .username:
                cell.name.text = "@\(resultName)"
            case .location:
                cell.name.text = resultName
            }
        }
        else {
            cell.name.text = ""
        }

        cell.selectionStyle = .none
        if let image = item.result.image {
            cell.avatar.setUserAvatar(image)
        }
        else if let url = item.result.url {
            cell.avatar.setUserAvatarURL(url)
        }
    }
}
