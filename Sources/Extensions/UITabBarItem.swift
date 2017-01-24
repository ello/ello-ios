////
///  UITabBarItem.swift
//

extension UITabBarItem {
    static func item(_ interfaceImage: InterfaceImage, insets: UIEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)) -> UITabBarItem {
        let iconImage = interfaceImage.normalImage
        let iconSelectedImage = interfaceImage.selectedImage
        let item = UITabBarItem(title: nil, image: iconImage, selectedImage: iconSelectedImage)
        item.imageInsets = insets
        return item
    }
}
