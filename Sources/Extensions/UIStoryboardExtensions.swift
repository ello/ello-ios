////
///  UIStoryboardExtensions.swift
//

extension UIStoryboard {

    class func storyboardWithId(_ identifier: StoryboardIdentifier, storyboardName: String = "Main") -> UIViewController {
        return UIStoryboard(name: storyboardName, bundle: Bundle(for: AppDelegate.self)).instantiateViewController(withIdentifier: identifier.rawValue)
    }
}
