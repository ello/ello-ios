////
///  Animators.swift
//

let TransitionAnimationDuration: TimeInterval = 0.25

class ForwardAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TransitionAnimationDuration
    }

    func animateTransition(using context: UIViewControllerContextTransitioning) {
        let toView = (context.viewController(forKey: UITransitionContextViewControllerKey.to)?.view)!
        let fromView = (context.viewController(forKey: UITransitionContextViewControllerKey.from)?.view)!

        let from = fromView.frame
        toView.frame.origin.x = toView.frame.size.width
        context.containerView.addSubview(toView)

        UIView.animate(withDuration: transitionDuration(using: context),
            delay: 0.0,
            options: .curveEaseIn,
            animations: {
                toView.frame = from
                fromView.frame.origin.x -= fromView.frame.size.width
            },
            completion: { _ in
                context.completeTransition(!context.transitionWasCancelled)
        })
    }
}

class BackAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TransitionAnimationDuration
    }

    func animateTransition(using context: UIViewControllerContextTransitioning) {
        let toView = (context.viewController(forKey: UITransitionContextViewControllerKey.to)?.view)!
        let fromView = (context.viewController(forKey: UITransitionContextViewControllerKey.from)?.view)!

        let from = fromView.frame
        toView.frame.origin.x = -toView.frame.size.width
        context.containerView.addSubview(toView)

        UIView.animate(withDuration: transitionDuration(using: context),
            delay: 0.0,
            options: .curveEaseIn,
            animations: {
                toView.frame = from
                fromView.frame.origin.x += fromView.frame.size.width
            },
            completion: { _ in
                context.completeTransition(!context.transitionWasCancelled)
        })
    }
}
