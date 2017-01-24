////
///  DrawerAnimators.swift
//

typealias Animator = (_ animations: @escaping () -> Void, _ completion: @escaping (Bool) -> Void) -> Void

class DrawerAnimator: NSObject, UIViewControllerTransitioningDelegate  {
    let popControl = DrawerPopControl()

    func animationController(
        forPresented presented: UIViewController, presenting: UIViewController,
        source: UIViewController
        ) -> UIViewControllerAnimatedTransitioning? {
            popControl.presentingController = presenting
            return DrawerPushAnimator(popControl: popControl)
    }

    func animationController(
        forDismissed dismissed: UIViewController
        ) -> UIViewControllerAnimatedTransitioning? {
            return DrawerPopAnimator(popControl: popControl)
    }

}

class DrawerPushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let popControl: DrawerPopControl

    init(popControl: DrawerPopControl) {
        self.popControl = popControl
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TransitionAnimationDuration
    }

    func animateTransition(using context: UIViewControllerContextTransitioning) {
        let streamController = context.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let drawerView = context.view(forKey: UITransitionContextViewKey.to)!
        let streamView = streamController.view
        let containerView = context.containerView
        let animator: Animator = { animations, completion in
            UIView.animate(withDuration: self.transitionDuration(using: context),
                delay: 0.0,
                options: .curveEaseIn,
                animations: animations,
                completion: completion
                )
        }

        animateTransition(
            streamView: streamView!, drawerView: drawerView, containerView: containerView,
            animator: animator
        ) {
            context.completeTransition(!context.transitionWasCancelled)
        }
    }

    func animateTransition(
        streamView: UIView, drawerView: UIView, containerView: UIView,
        animator: Animator, completion: @escaping () -> Void
    ) {
        popControl.frame = streamView.bounds

        drawerView.frame = streamView.frame
        containerView.addSubview(drawerView)
        streamView.addSubview(popControl)
        drawerView.addSubview(streamView)

        animator({
            let deltaX = streamView.frame.size.width - 150
            streamView.frame.origin.x += deltaX
        }, { _ in
            completion()
        })
    }
}

class DrawerPopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let popControl: DrawerPopControl

    init(popControl: DrawerPopControl) {
        self.popControl = popControl
        super.init()
    }

    func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
        if let drawerController = context?.viewController(forKey: UITransitionContextViewControllerKey.from) as? DrawerViewController {
            if drawerController.isLoggingOut {
                return 0
            }
        }
        return TransitionAnimationDuration
    }

    func animateTransition(using context: UIViewControllerContextTransitioning) {
        let streamController = context.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let streamView = streamController.view
        let drawerView = context.view(forKey: UITransitionContextViewKey.from)!
        let containerView = context.containerView
        let animator: Animator = { animations, completion in
            UIView.animate(withDuration: self.transitionDuration(using: context),
                delay: 0.0,
                options: .curveEaseIn,
                animations: animations,
                completion: completion
                )
        }

        animateTransition(
            streamView: streamView!, drawerView: drawerView, containerView: containerView,
            animator: animator
        ) {
            context.completeTransition(!context.transitionWasCancelled)
        }
    }

    func animateTransition(
        streamView: UIView, drawerView: UIView, containerView: UIView,
        animator: Animator, completed: @escaping () -> Void
    ) {
        containerView.insertSubview(drawerView, at: 0)

        animator({
            self.popControl.frame.origin.x = 0
            streamView.frame.origin.x = 0
        }, { _ in
            self.popControl.removeFromSuperview()
            drawerView.removeFromSuperview()
            completed()

            if let windowOpt = UIApplication.shared.delegate?.window,
                let window = windowOpt,
                let rootViewController = window.rootViewController
            {
                window.addSubview(rootViewController.view)
            }
        })
    }
}
