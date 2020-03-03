////
///  UIButtonExtensions.swift
//

extension UIButton {

    func setImage(_ interfaceImage: InterfaceImage, imageStyle: InterfaceImage.Style, for state: UIControl.State) {
        self.setImage(interfaceImage.image(imageStyle), for: state)
    }

    func setImages(_ interfaceImage: InterfaceImage, style imageStyle: InterfaceImage.Style = .normal) {
        if #available(iOS 13, *) {
            switch (imageStyle, UITraitCollection.current.userInterfaceStyle) {
            case (.selected, .dark):
                self.setImage(interfaceImage.whiteImage, for: .normal)
            case (.dynamic, _), (.inverted, _):
                self.setImage(interfaceImage.normalImage, for: .normal)
            default:
                self.setImage(interfaceImage.image(imageStyle), for: .normal)
            }
        }
        else {
            self.setImage(interfaceImage.image(imageStyle), for: .normal)
        }

        if #available(iOS 13, *) {
            switch (imageStyle, UITraitCollection.current.userInterfaceStyle) {
            case (.dynamic, .dark), (.inverted, .light):
                self.setImage(interfaceImage.whiteImage, for: .selected)
            case (.dynamic, .light), (.inverted, .dark):
                self.setImage(interfaceImage.selectedImage, for: .selected)
            default:
                self.setImage(interfaceImage.selectedImage, for: .selected)
            }
        }
        else {
            self.setImage(interfaceImage.selectedImage, for: .selected)
        }
    }
}
