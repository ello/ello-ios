////
///  QuickExtensions.swift
//

@testable
import Ello
import Quick
import Nimble
import Nimble_Snapshots


var prevController: UITabBarController?
func showController(viewController: UIViewController) {
    let frame: CGRect
    let view = viewController.view
    if view.frame.size.width > 0 && view.frame.size.height > 0 {
        frame = CGRect(origin: CGPointZero, size: view.frame.size)
    }
    else {
        frame = UIScreen.mainScreen().bounds
    }

    viewController.loadViewIfNeeded()

    prevController?.viewControllers = []
    let window = UIWindow()
    let parentController = UITabBarController()
    parentController.tabBar.hidden = true
    parentController.viewControllers = [viewController]
    window.rootViewController = parentController
    window.frame = frame
    window.makeKeyAndVisible()
    viewController.view.layoutIfNeeded()
    prevController = parentController
}

func showView(view: UIView) {
    let controller = UIViewController()
    controller.view.frame.size = view.frame.size
    view.frame.origin = CGPointZero
    controller.view.addSubview(view)
    showController(controller)
}

public enum SnapshotDevice {
    case Pad_Landscape
    case Pad_Portrait
    case Phone4_Portrait
    case Phone5_Portrait
    case Phone6_Portrait
    case Phone6Plus_Portrait
    case Custom(CGSize)

    static let all: [SnapshotDevice] = [
        .Pad_Landscape,
        .Pad_Portrait,
        .Phone4_Portrait,
        .Phone5_Portrait,
        .Phone6_Portrait,
        .Phone6Plus_Portrait,
    ]

    var description: String {
        switch self {
        case Pad_Landscape: return "iPad in Landscape"
        case Pad_Portrait: return "iPad in Portrait"
        case Phone4_Portrait: return "iPhone4 in Portrait"
        case Phone5_Portrait: return "iPhone5 in Portrait"
        case Phone6_Portrait: return "iPhone6 in Portrait"
        case Phone6Plus_Portrait: return "iPhone6Plus in Portrait"
        case let Custom(size): return "Custom sized \(size)"
        }
    }

    var size: CGSize {
        switch self {
        case Pad_Landscape: return CGSize(width: 1024, height: 768)
        case Pad_Portrait: return CGSize(width: 768, height: 1024)
        case Phone4_Portrait: return CGSize(width: 320, height: 480)
        case Phone5_Portrait: return CGSize(width: 320, height: 568)
        case Phone6_Portrait: return CGSize(width: 375, height: 667)
        case Phone6Plus_Portrait: return CGSize(width: 414, height: 736)
        case let Custom(size): return size
        }
    }
}

func expectValidSnapshot(subject: Snapshotable, named name: String? = nil, device: SnapshotDevice, record: Bool = false, file: String = #file, line: UInt = #line) {
    prepareForSnapshot(subject, size: device.size)
    let localName: String?
    if let name = name {
        localName = "\(name) on \(device.description)"
    }
    else {
        localName = nil
    }
    expect(subject, file: file, line: line).to(record ? recordSnapshot(named: localName) : haveValidSnapshot(named: localName))
}

func validateAllSnapshots(named name: String? = nil, record: Bool = false, file: String = #file, line: UInt = #line, subject: () -> Snapshotable) {
    for device in SnapshotDevice.all {
        context(device.description) {
            describe("view") {
                it("should match the screenshot", file: file, line: line) {
                    expectValidSnapshot(subject(), named: name, device: device, record: record, file: file, line: line)
                }
            }
        }
    }
}

func prepareForSnapshot(subject: Snapshotable, device: SnapshotDevice) {
    prepareForSnapshot(subject, size: device.size)
}

func prepareForSnapshot(subject: Snapshotable, size: CGSize) {
    let parent = UIView(frame: CGRect(origin: CGPointZero, size: size))
    let view = subject.snapshotObject!
    view.frame = parent.bounds
    parent.addSubview(view)
    view.layoutIfNeeded()
    showView(view)
}


public extension UIStoryboard {

    class func storyboardWithId(identifier: String, storyboardName: String = "Main") -> UIViewController {
        return UIStoryboard(name: storyboardName, bundle: NSBundle(forClass: AppDelegate.self)).instantiateViewControllerWithIdentifier(identifier)
    }

}

public func haveRegisteredIdentifier<T: UITableView>(identifier: String) -> NonNilMatcherFunc<T> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "\(identifier) should be registered"
        let tableView = try! actualExpression.evaluate() as! UITableView
        tableView.reloadData()
        // Using the side effect of a runtime crash when dequeing a cell here, if it works :thumbsup:
        let _ = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        return true
    }
}

public func beVisibleIn<S: UIView>(view: UIView) -> NonNilMatcherFunc<S> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be visible in \(view)"
        let childView = try! actualExpression.evaluate()
        if let childView = childView {
            if childView.hidden || childView.alpha < 0.01 || childView.frame.size.width < 0.1 || childView.frame.size.height < 0.1 {
                return false
            }

            var parentView: UIView? = childView.superview
            while parentView != nil {
                if let parentView = parentView where parentView == view {
                    return true
                }
                parentView = parentView!.superview
            }
        }
        return false
    }
}

public func checkRegions(regions: [OmnibarRegion], contain text: String) {
    for region in regions {
        if let regionText = region.text where regionText.string.contains(text) {
            expect(regionText.string).to(contain(text))
            return
        }
    }
    fail("could not find \(text) in regions \(regions)")
}

public func checkRegions(regions: [OmnibarRegion], notToContain text: String) {
    for region in regions {
        if let regionText = region.text where regionText.string.contains(text) {
            expect(regionText.string).notTo(contain(text))
        }
    }
}

public func checkRegions(regions: [OmnibarRegion], equal text: String) {
    for region in regions {
        if let regionText = region.text where regionText.string == text {
            expect(regionText.string) == text
            return
        }
    }
    fail("could not find \(text) in regions \(regions)")
}

public func haveImageRegion<S: OmnibarScreenProtocol>() -> NonNilMatcherFunc<S> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "have image"

        if let screen = try! actualExpression.evaluate() {
            for region in screen.regions {
                if region.image != nil {
                    return true
                }
            }
        }
        return false
    }
}

public func haveImageRegion<S: OmnibarScreenProtocol>(equal image: UIImage) -> NonNilMatcherFunc<S> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "have image that equals \(image)"

        if let screen = try! actualExpression.evaluate() {
            for region in screen.regions {
                if let regionImage = region.image where regionImage == image {
                    return true
                }
            }
        }
        return false
    }
}

private func allSubviews(view: UIView) -> [UIView] {
    return view.subviews + view.subviews.flatMap { allSubviews($0) }
}

public func subviewThatMatches<T where T: UIView>(view: UIView, test: (UIView) -> Bool) -> T? {
    for subview in allSubviews(view) {
        if test(subview) {
            return subview as? T
        }
    }
    return nil
}

public func haveSubview<V: UIView>(thatMatches test: (UIView) -> Bool) -> NonNilMatcherFunc<V> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "have subview that matches"

        let view = try! actualExpression.evaluate()
        if let view = view {
            return subviewThatMatches(view, test: test) != nil
        }
        return false
    }
}
