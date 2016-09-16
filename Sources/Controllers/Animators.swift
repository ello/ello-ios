////
///  Animators.swift
//

public let TransitionAnimationDuration: NSTimeInterval = 0.25

public class ForwardAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return TransitionAnimationDuration
    }

    public func animateTransition(context: UIViewControllerContextTransitioning) {
        let toView = (context.viewControllerForKey(UITransitionContextToViewControllerKey)?.view)!
        let fromView = (context.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view)!

        let from = fromView.frame
        toView.frame.origin.x = toView.frame.size.width
        context.containerView().addSubview(toView)

        UIView.animateWithDuration(transitionDuration(context),
            delay: 0.0,
            options: .CurveEaseIn,
            animations: {
                toView.frame = from
                fromView.frame.origin.x -= fromView.frame.size.width
            },
            completion: { _ in
                context.completeTransition(!context.transitionWasCancelled())
        })
    }
}

public class BackAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return TransitionAnimationDuration
    }

    public func animateTransition(context: UIViewControllerContextTransitioning) {
        let toView = (context.viewControllerForKey(UITransitionContextToViewControllerKey)?.view)!
        let fromView = (context.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view)!

        let from = fromView.frame
        toView.frame.origin.x = -toView.frame.size.width
        context.containerView().addSubview(toView)

        UIView.animateWithDuration(transitionDuration(context),
            delay: 0.0,
            options: .CurveEaseIn,
            animations: {
                toView.frame = from
                fromView.frame.origin.x += fromView.frame.size.width
            },
            completion: { _ in
                context.completeTransition(!context.transitionWasCancelled())
        })
    }
}
