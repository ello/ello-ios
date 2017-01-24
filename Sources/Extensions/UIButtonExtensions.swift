////
///  UIButtonExtensions.swift
//

extension UIButton {

    func setImage(_ interfaceImage: InterfaceImage, imageStyle: InterfaceImage.Style, for state: UIControlState) {
        self.setImage(interfaceImage.image(imageStyle), for: state)
    }

    func setImages(_ interfaceImage: InterfaceImage, degree: Double = 0, white: Bool = false) {
        if white {
            self.setImage(interfaceImage.whiteImage, for: .normal, degree: degree)
        }
        else {
            self.setImage(interfaceImage.normalImage, for: .normal, degree: degree)
        }
        self.setImage(interfaceImage.selectedImage, for: .selected, degree: degree)
    }

    func setImage(_ image: UIImage!, for state: UIControlState = .normal, degree: Double) {
        self.setImage(image, for: state)
        if degree != 0 {
            let radians = (degree * M_PI) / 180.0
            transform = CGAffineTransform(rotationAngle: CGFloat(radians))
        }
    }
}
