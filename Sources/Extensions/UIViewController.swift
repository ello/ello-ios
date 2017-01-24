////
///  UIViewController.swift
//

@objc protocol GestureNavigation {
    var backGestureEdges: UIRectEdge { get }
    func backGestureAction() -> Void
}

extension UIViewController: GestureNavigation {
    var backGestureEdges: UIRectEdge { return .left }

    func backGestureAction() {
        if (navigationController?.viewControllers.count)! > 1 {
            _ = navigationController?.popViewController(animated: true)
        }
    }

    func findViewController(_ find: (UIViewController) -> Bool) -> UIViewController? {
        var controller: UIViewController?
        controller = self
        while controller != nil {
            if find(controller!) {
                return controller
            }
            controller = controller!.parent
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
        animations: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) -> Void
    {
        if AppSetup.sharedState.isTesting {
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
