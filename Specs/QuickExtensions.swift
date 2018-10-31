////
///  QuickExtensions.swift
//

@testable import Ello
import Quick
import Nimble
import Nimble_Snapshots


func showController(_ viewController: UIViewController, window: UIWindow = UIWindow()) {
    let frame: CGRect
    let view: UIView = viewController.view
    if view.frame.size.width > 0 && view.frame.size.height > 0 {
        frame = CGRect(origin: .zero, size: view.frame.size)
    }
    else {
        frame = UIScreen.main.bounds
    }

    viewController.loadViewIfNeeded()

    window.rootViewController = viewController
    window.frame = frame
    window.makeKeyAndVisible()
    viewController.view.layoutIfNeeded()
}

func showView(_ view: UIView, container: UIView = UIView()) {
    let controller = UIViewController()
    controller.view.frame.size = view.frame.size
    container.frame.size = view.frame.size
    view.frame.origin = .zero
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.translatesAutoresizingMaskIntoConstraints = true
    container.addSubview(view)
    controller.view.addSubview(container)

    showController(controller)
}

enum SnapshotDevice {
    case pad_Landscape
    case pad_Portrait
    case phone4_Portrait
    case phone5_Portrait
    case phone6_Portrait
    case phone6Plus_Portrait
    case custom(CGSize)

    static let all: [SnapshotDevice] = [
        .pad_Landscape,
        .pad_Portrait,
        .phone4_Portrait,
        .phone5_Portrait,
        .phone6_Portrait,
        .phone6Plus_Portrait,
    ]

    var description: String {
        switch self {
        case .pad_Landscape: return "iPad in Landscape"
        case .pad_Portrait: return "iPad in Portrait"
        case .phone4_Portrait: return "iPhone4 in Portrait"
        case .phone5_Portrait: return "iPhone5 in Portrait"
        case .phone6_Portrait: return "iPhone6 in Portrait"
        case .phone6Plus_Portrait: return "iPhone6Plus in Portrait"
        case let .custom(size): return "Custom sized \(size)"
        }
    }

    var size: CGSize {
        switch self {
        case .pad_Landscape: return CGSize(width: 1024, height: 768)
        case .pad_Portrait: return CGSize(width: 768, height: 1024)
        case .phone4_Portrait: return CGSize(width: 320, height: 480)
        case .phone5_Portrait: return CGSize(width: 320, height: 568)
        case .phone6_Portrait: return CGSize(width: 375, height: 667)
        case .phone6Plus_Portrait: return CGSize(width: 414, height: 736)
        case let .custom(size): return size
        }
    }
}

func expectValidSnapshot(_ subject: Snapshotable, named name: String? = nil, device: SnapshotDevice? = nil, record: Bool = false, file: String = #file, line: UInt = #line) {
    if let size = device?.size ?? subject.snapshotObject?.frame.size {
        prepareForSnapshot(subject, size: size)
    }

    let localName: String?
    if let name = name, let device = device {
        localName = "\(name) on \(device.description)"
    }
    else if let name = name {
        localName = name
    }
    else {
        localName = nil
    }

    expect(subject, file: file, line: line).to(record ? recordSnapshot(named: localName) : haveValidSnapshot(named: localName))
}

func validateAllSnapshots(named name: String? = nil, record: Bool = false, file: String = #file, line: UInt = #line, subject: @escaping () -> Snapshotable) {
    for device in SnapshotDevice.all {
        context(device.description) {
            it("should match the screenshot", file: file, line: line) {
                expectValidSnapshot(subject(), named: name, device: device, record: record, file: file, line: line)
            }
        }
    }
}

func prepareForSnapshot(_ subject: Snapshotable, device: SnapshotDevice) {
    prepareForSnapshot(subject, size: device.size)
}

func prepareForSnapshot(_ subject: Snapshotable, size: CGSize) {
    let parent = UIView(frame: CGRect(origin: .zero, size: size))
    let view = subject.snapshotObject!

    view.frame = parent.bounds
    parent.addSubview(view)
    showView(view)
    view.setNeedsLayout()
    view.layoutIfNeeded()

    // wtf is up w/ ios 11 / xcode 9?  this finds all views with clear background
    // and *reassigns* the clear background
    let allClearSubviews: [UIView] = view.findAllSubviews { return $0.backgroundColor == nil }
    allClearSubviews.forEach { v in
        v.backgroundColor = .clear
    }
    // another weird fix, table view separators aren't hiding:
    let tableViews: [UITableView] = view.findAllSubviews { v in v.separatorStyle == .none }
    let separators: [UIView] = tableViews.flatMap({ $0.findAllSubviews { v in
        return v.readableClassName() == "_UITableViewCellSeparatorView"
        }})
    for separator in separators {
        separator.isHidden = true
    }
    // and UIPageControls don't display at all, so color them just to have
    // something in the snapshot spec
    let pageControls: [UIPageControl] = view.findAllSubviews()
    for pc in pageControls {
        pc.backgroundColor = .black
    }
}


extension UIStoryboard {

    class func storyboardWithId(_ identifier: String, storyboardName: String = "Main") -> UIViewController {
        return UIStoryboard(name: storyboardName, bundle: Bundle(for: AppDelegate.self)).instantiateViewController(withIdentifier: identifier)
    }

}

func haveRegisteredIdentifier<T: UITableView>(_ identifier: String) -> Predicate<T> {
    return Predicate.define("\(identifier) should be registered") { actualExpression, msg in
        let tableView = try! actualExpression.evaluate()!
        tableView.reloadData()
        // Using the side effect of a runtime crash when dequeing a cell here, if it works :thumbsup:
        let _ = tableView.dequeueReusableCell(withIdentifier: identifier, for: IndexPath(row: 0, section: 0))
        return PredicateResult(status: PredicateStatus(bool: true), message: msg)
    }
}

func beVisibleIn<S: UIView>(_ view: UIView) -> Predicate<S> {
    return Predicate.define("be visible in \(view)") { actualExpression, msg -> PredicateResult in
        guard
            let subject = try? actualExpression.evaluate(),
            let childView = subject
        else { return PredicateResult(status: .fail, message: msg) }

        if childView.isHidden || childView.alpha < 0.01 || childView.frame.size.width < 0.1 || childView.frame.size.height < 0.1 {
            return PredicateResult(status: .fail, message: msg)
        }

        var parentView: UIView? = childView.superview
        while parentView != nil {
            if let parentView = parentView, parentView == view {
                return PredicateResult(status: PredicateStatus(bool: true), message: msg)
            }
            parentView = parentView!.superview
        }
        return PredicateResult(status: .fail, message: msg)
    }
}

func checkRegions(_ regions: [OmnibarRegion], contain text: String) {
    for region in regions {
        if let regionText = region.text, regionText.string.contains(text) {
            expect(regionText.string).to(contain(text))
            return
        }
    }
    fail("could not find \(text) in regions \(regions)")
}

func checkRegions(_ regions: [OmnibarRegion], notToContain text: String) {
    for region in regions {
        if let regionText = region.text, regionText.string.contains(text) {
            expect(regionText.string).notTo(contain(text))
        }
    }
}

func checkRegions(_ regions: [OmnibarRegion], equal text: String) {
    for region in regions {
        if let regionText = region.text, regionText.string == text {
            expect(regionText.string) == text
            return
        }
    }
    fail("could not find \(text) in regions \(regions)")
}

func haveImageRegion<S: OmnibarScreenProtocol>() -> Predicate<S> {
    return Predicate.define("have image") { actualExpression, msg in
        if let screen = try! actualExpression.evaluate() {
            for region in screen.regions {
                if region.image != nil {
                    return PredicateResult(status: PredicateStatus(bool: true), message: msg)
                }
            }
        }
        return PredicateResult(status: .fail, message: msg)
    }
}

func haveImageRegion<S: OmnibarScreenProtocol>(equal image: UIImage) -> Predicate<S> {
    return Predicate.define("have image that equals \(image)") { actualExpression, msg in
        if let screen = try! actualExpression.evaluate() {
            for region in screen.regions {
                if let regionImage = region.image, regionImage == image {
                    return PredicateResult(status: PredicateStatus(bool: true), message: msg)
                }
            }
        }
        return PredicateResult(status: .fail, message: msg)
    }
}

func haveSubview<V: UIView>(thatMatches test: @escaping (UIView) -> Bool) -> Predicate<V> {
    return Predicate.define("have subview that matches") { actualExpression, msg in
        let view = try! actualExpression.evaluate()
        if let view = view {
            let foundView: UIView? = view.findSubview(test)
            return PredicateResult(status: PredicateStatus(bool: foundView != nil), message: msg)
        }
        return PredicateResult(status: .fail, message: msg)
    }
}
