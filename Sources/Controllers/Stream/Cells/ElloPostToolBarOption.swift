////
///  ElloPostToolBarOption.swift
//

enum ElloPostToolBarOption {
    case views
    case comments
    case loves
    case repost
    case delete
    case edit
    case reply
    case flag

    func imageLabelControl(isDark: Bool) -> UIControl {
        switch self {
        case .views:
            return imageLabelControl(.eye, isDark: isDark)
        case .comments:
            return ImageLabelControl(icon: CommentsIcon(isDark: isDark), title: "")
        case .loves:
            return imageLabelControl(.heart, isDark: isDark)
        case .repost:
            return imageLabelControl(.repost, isDark: isDark)
        case .delete:
            return imageLabelControl(.xBox, isDark: isDark)
        case .edit:
            return imageLabelControl(.pencil, isDark: isDark)
        case .reply:
            return imageLabelControl(.reply, isDark: isDark)
        case .flag:
            return imageLabelControl(.flag, isDark: isDark)
        }
    }

    func barButtonItem(isDark: Bool) -> UIBarButtonItem {
        return UIBarButtonItem(customView: self.imageLabelControl(isDark: isDark))
    }

    private func imageLabelControl(_ interfaceImage: InterfaceImage, isDark: Bool) -> UIControl {
        let icon = UIImageView(image: interfaceImage.normalImage)
        let iconSelected: UIImageView
        if isDark {
            iconSelected = UIImageView(image: interfaceImage.whiteImage)
        }
        else {
            iconSelected = UIImageView(image: interfaceImage.selectedImage)
        }

        var iconDisabled: UIView?
        if let disabledImage = interfaceImage.disabledImage {
            iconDisabled = UIImageView(image: disabledImage)
        }
        let basicIcon = BasicIcon(
            normalIconView: icon,
            selectedIconView: iconSelected,
            disabledIconView: iconDisabled
        )
        return ImageLabelControl(icon: basicIcon, title: "")
    }

}
