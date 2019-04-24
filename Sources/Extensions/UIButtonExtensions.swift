////
///  UIButtonExtensions.swift
//

extension UIButton {

    func setImage(_ interfaceImage: InterfaceImage, imageStyle: InterfaceImage.Style, for state: UIControl.State) {
        self.setImage(interfaceImage.image(imageStyle), for: state)
    }

    func setImages(_ interfaceImage: InterfaceImage, style imageStyle: InterfaceImage.Style = .normal) {
        self.setImage(interfaceImage.image(imageStyle), for: .normal)
        self.setImage(interfaceImage.selectedImage, for: .selected)
    }
}
