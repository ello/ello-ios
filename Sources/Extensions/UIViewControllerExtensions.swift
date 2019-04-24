////
///  UIViewController.swift
//

@objc protocol GestureNavigation {
    var backGestureEdges: UIRectEdge { get }
    func backGestureAction()
}

private func findTopMostViewController(_ controller: UIViewController) -> UIViewController {
    if let controller = controller as? UINavigationController {
        return controller.visibleViewController?.topMostViewController ?? controller
    }
    if let controller = controller as? UITabBarController {
        return controller.selectedViewController?.topMostViewController ?? controller
    }
    if let controller = controller as? AppViewController {
        return controller.visibleViewController?.topMostViewController ?? controller
    }
    if let controller = controller as? LoggedOutViewController {
        return controller.children.first?.topMostViewController ?? controller
    }
    if let controller = controller as? HomeViewController {
        return controller.visibleViewController?.topMostViewController ?? controller
    }
    if let controller = controller as? OnboardingViewController {
        return controller.visibleViewController?.topMostViewController ?? controller
    }
    if let controller = controller as? ElloTabBarController {
        return controller.selectedViewController.topMostViewController
    }
    return controller
}

extension UIViewController: GestureNavigation {
    var backGestureEdges: UIRectEdge { return .left }

    func backGestureAction() {
        if (navigationController?.viewControllers.count)! > 1 {
            _ = navigationController?.popViewController(animated: true)
        }
    }

    func findParentController<T>(_ test: ((T) -> Bool)? = nil) -> T? {
        if let controller = self as? T, test?(controller) ?? true {
            return controller
        }

        if let parentController = (parent ?? presentingViewController) {
            return parentController.findParentController(test)
        }

        return nil
    }

    func findChildController<T>(_ test: ((T) -> Bool)? = nil) -> T? {
        let sanityTest: (UIViewController?) -> T? = { controller in
            guard
                let controller = controller,
                controller.isViewLoaded, controller.view.window != nil,
                let testType = controller as? T,
                test?(testType) != false
            else { return nil }
            return testType
        }

        if let controller = sanityTest(self) ?? sanityTest(presentedViewController) {
            return controller
        }

        for subcontroller in children {
            guard let subcontroller: T = subcontroller.findChildController(test) else { continue }
            return subcontroller
        }

        return nil
    }

    var topMostViewController: UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController
        }
        return findTopMostViewController(self)
    }

}

extension UIViewController {

    func transitionControllers(
        from fromViewController: UIViewController,
        to toViewController: UIViewController,
        duration: TimeInterval = 0,
        options: UIView.AnimationOptions = [],
        animations: Block? = nil, completion: BoolBlock? = nil)
    {
        if Globals.isTesting {
            animations?()
            self.transition(from: fromViewController,
                to: toViewController,
                duration: duration,
                options: options,
                animations: nil,
                completion: nil)
            completion?(true)
        }
        else {
            self.transition(from: fromViewController,
                to: toViewController,
                duration: duration,
                options: options,
                animations: animations,
                completion: completion)
        }
    }
}
