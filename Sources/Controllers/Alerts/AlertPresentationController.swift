////
///  AlertPresentationController.swift
//

import UIKit

public class AlertPresentationController: UIPresentationController {

    let background: UIView = {
        let background = UIView(frame: .zero)
        background.backgroundColor = UIColor.modalBackground()
        return background
    }()

    public init(presentedViewController: UIViewController, presentingViewController: UIViewController?, backgroundColor: UIColor) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        self.background.backgroundColor = backgroundColor
    }
}

// MARK: View Lifecycle
public extension AlertPresentationController {
    override public func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        let alertViewController = presentedViewController as! AlertViewController
        alertViewController.resize()

        let gesture = UITapGestureRecognizer(target:self, action: #selector(AlertPresentationController.dismiss))
        background.addGestureRecognizer(gesture)
    }
}

// MARK: Presentation
public extension AlertPresentationController {
    override public func presentationTransitionWillBegin() {
        if let containerView = containerView {
            background.alpha = 0
            background.frame = containerView.bounds
            containerView.addSubview(background)

            let transitionCoordinator = presentingViewController.transitionCoordinator()
            transitionCoordinator?.animateAlongsideTransition({ _ in
                self.background.alpha = 1
                }, completion: .None)
            if let presentedView = presentedView() {
                containerView.addSubview(presentedView)
            }
        }
    }

    override public func dismissalTransitionWillBegin() {
        let transitionCoordinator = presentingViewController.transitionCoordinator()
        transitionCoordinator?.animateAlongsideTransition({ _ in
            self.background.alpha = 0
        }, completion: .None)
    }

    override public func dismissalTransitionDidEnd(completed: Bool) {
        if completed {
            background.removeFromSuperview()
        }
    }
}

extension AlertPresentationController {
    func dismiss() {
        let alertViewController = presentedViewController as! AlertViewController
        if alertViewController.dismissable {
            presentedViewController.dismissViewControllerAnimated(true, completion: .None)
        }
    }
}
