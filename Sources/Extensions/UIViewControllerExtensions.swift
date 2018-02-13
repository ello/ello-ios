////
///  UIViewController.swift
//

@objc protocol GestureNavigation {
    var backGestureEdges: UIRectEdge { get }
    func backGestureAction()
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

}

extension UIViewController {

    func transitionControllers(
        from fromViewController: UIViewController,
        to toViewController: UIViewController,
        duration: TimeInterval = 0,
        options: UIViewAnimationOptions = [],
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
