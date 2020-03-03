////
///  ElloTab.swift
//

enum ElloTab: Int {
    case home
    case discover
    case omnibar
    case notifications
    case profile

    static let defaultTab: ElloTab = .home

    static func resetToolTips() {
        GroupDefaults[ElloTab.home.narrationDefaultKey] = nil
        GroupDefaults[ElloTab.discover.narrationDefaultKey] = nil
        GroupDefaults[ElloTab.notifications.narrationDefaultKey] = nil
        GroupDefaults[ElloTab.profile.narrationDefaultKey] = nil
        GroupDefaults[ElloTab.omnibar.narrationDefaultKey] = nil
    }

    func customImages(profile: UIImage?) -> (UIImage, UIImage)? {
        guard
            let profile = profile,
            case .profile = self
        else { return nil }

        guard let squareImage = profile.squareImage(),
            let resizedImage = squareImage.resizeToSize(CGSize(width: 38, height: 38), padding: 4),
            let roundedImage = resizedImage.toCircle(padding: 4)
        else { return nil }

        let image = roundedImage.withRenderingMode(.alwaysOriginal)
        return (image, circleOutline(image: image))
    }

    var interfaceImage: InterfaceImage {
        switch self {
        case .home: return .home
        case .discover: return .discover
        case .omnibar: return .omni
        case .notifications: return .bolt
        case .profile: return .person
        }
    }

    var redDotMargins: CGPoint {
        switch self {
        case .notifications: return CGPoint(x: 12, y: 9)
        case .home:          return CGPoint(x: 12, y: 9)
        default:             return .zero
        }
    }

    var narrationDefaultKey: String {
        let defaultPrefix = "ElloTabBarControllerDidShowNarration"
        switch self {
        case .home:     return "\(defaultPrefix)Stream"
        case .discover:      return "\(defaultPrefix)Discover"
        case .omnibar:       return "\(defaultPrefix)Omnibar"
        case .notifications: return "\(defaultPrefix)Notifications"
        case .profile:       return "\(defaultPrefix)Profile"
        }
    }

    var narrationTitle: String {
        switch self {
        case .home:     return InterfaceString.Tab.PopupTitle.Following
        case .discover:      return InterfaceString.Tab.PopupTitle.Discover
        case .omnibar:       return InterfaceString.Tab.PopupTitle.Omnibar
        case .notifications: return InterfaceString.Tab.PopupTitle.Notifications
        case .profile:       return InterfaceString.Tab.PopupTitle.Profile
        }
    }

    var narrationText: String {
        switch self {
        case .home:     return InterfaceString.Tab.PopupText.Following
        case .discover:      return InterfaceString.Tab.PopupText.Discover
        case .omnibar:       return InterfaceString.Tab.PopupText.Omnibar
        case .notifications: return InterfaceString.Tab.PopupText.Notifications
        case .profile:       return InterfaceString.Tab.PopupText.Profile
        }
    }

}

private func circleOutline(image: UIImage) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
    image.draw(in: rect)
    let ctx = UIGraphicsGetCurrentContext()
    ctx?.saveGState()
    ctx?.setStrokeColor(UIColor.background.cgColor)
    ctx?.setLineWidth(3)
    ctx?.strokeEllipse(in: rect.insetBy(dx: 1, dy: 1))

    ctx?.setStrokeColor(UIColor.text.cgColor)
    ctx?.setLineWidth(1)
    ctx?.strokeEllipse(in: rect.insetBy(dx: 1, dy: 1))
    ctx?.restoreGState()
    let img = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()

    return img.withRenderingMode(.alwaysOriginal)
}
