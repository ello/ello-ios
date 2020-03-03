////
///  UIBarButtonItemExtensions.swift
//

extension UIBarButtonItem {

    class func closeButton(target: Any, action: Selector) -> UIBarButtonItem {
        let closeItem = UIBarButtonItem(
            image: InterfaceImage.x.normalImage,
            style: .plain,
            target: target,
            action: action
        )
        return closeItem
    }

    convenience init(image: InterfaceImage, target: Any, action: Selector) {
        let frame = CGRect(x: 0, y: 0, width: 36.0, height: 44.0)
        let button = UIButton(frame: frame)
        button.setImage(image, imageStyle: .normal, for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)

        self.init(customView: button)
    }

}
