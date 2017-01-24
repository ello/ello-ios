////
///  UIBarButtonItem.swift
//

extension UIBarButtonItem {

    class func searchItem(controller: BaseElloViewController) -> UIBarButtonItem {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 44))
        button.addTarget(controller, action: #selector(BaseElloViewController.searchButtonTapped), for: .touchUpInside)
        button.setImage(.search, imageStyle: .normal, for: .normal)

        return UIBarButtonItem(customView: button)
    }

    class func gridListItem(delegate: GridListToggleDelegate, isGridView: Bool) -> UIBarButtonItem {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 44))
        let isGridView = isGridView
        button.addTarget(delegate, action: #selector(GridListToggleDelegate.gridListToggled(_:)), for: .touchUpInside)

        let item = UIBarButtonItem(customView: button)
        item.setImage(isGridView: isGridView)
        return item
    }

    class func backChevron(withController controller: BaseElloViewController) -> UIBarButtonItem {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 44))
        button.setImage(.angleBracket, imageStyle: .normal, for: .normal)
        // rotate 180 degrees to flip
        button.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        button.addTarget(controller, action: #selector(BaseElloViewController.backTapped), for: .touchUpInside)

        return UIBarButtonItem(customView: button)
    }

    class func backChevronWithTarget(_ target: AnyObject, action: Selector) -> UIBarButtonItem {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 36, height: 44))
        button.setImage(.angleBracket, imageStyle: .normal, for: .normal)
        // rotate 180 degrees to flip
        button.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        button.addTarget(target, action: action, for: .touchUpInside)

        return UIBarButtonItem(customView: button)
    }

    class func closeButton(target: AnyObject, action: Selector) -> UIBarButtonItem {
        let closeItem = UIBarButtonItem(image: InterfaceImage.x.normalImage, style: UIBarButtonItemStyle.plain, target: target, action: action)
        return closeItem
    }

    class func spacer(width: CGFloat) -> UIBarButtonItem {
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = width
        return spacer
    }

    convenience init(image: InterfaceImage, target: AnyObject, action: Selector) {
        let frame = CGRect(x: 0, y: 0, width: 36.0, height: 44.0)
        let button = UIButton(frame: frame)
        button.setImage(image, imageStyle: .normal, for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)

        self.init(customView: button)
    }

    func setImage(isGridView: Bool) {
        guard let button = customView as? UIButton else { return }

        button.setImage(isGridView ? .listView : .gridView, imageStyle: .normal, for: .normal)
    }

}
