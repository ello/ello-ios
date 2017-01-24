////
///  ElloPostToolBarOption.swift
//

enum ElloPostToolBarOption {
    case views
    case comments
    case loves
    case repost
    case share
    case delete
    case edit
    case reply
    case flag

    func imageLabelControl() -> UIControl {
        switch self {
        case .views:
            return imageLabelControl(.eye)
        case .comments:
            return ImageLabelControl(icon: CommentsIcon(), title: "")
        case .loves:
            return imageLabelControl(.heart)
        case .repost:
            return imageLabelControl(.repost)
        case .share:
            return imageLabelControl(.share)
        case .delete:
            return imageLabelControl(.xBox)
        case .edit:
            return imageLabelControl(.pencil)
        case .reply:
            return imageLabelControl(.reply)
        case .flag:
            return imageLabelControl(.flag)
        }
    }

    func barButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(customView: self.imageLabelControl())
    }

    fileprivate func imageLabelControl(_ interfaceImage: InterfaceImage, count: Int = 0) -> UIControl {
        let icon = UIImageView(image: interfaceImage.normalImage)
        let iconSelected = UIImageView(image: interfaceImage.selectedImage)
        var iconDisabled: UIView? = nil
        if let disabledImage = interfaceImage.disabledImage {
            iconDisabled = UIImageView(image: disabledImage)
        }
        let basicIcon = BasicIcon(normalIconView: icon, selectedIconView: iconSelected, disabledIconView: iconDisabled)
        return ImageLabelControl(icon: basicIcon, title: count.numberToHuman())
    }

}
