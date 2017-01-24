////
///  AlertPresentationController.swift
//

import UIKit

class AlertPresentationController: UIPresentationController {

    let background: UIView = {
        let background = UIView(frame: .zero)
        background.backgroundColor = UIColor.modalBackground()
        return background
    }()

    init(presentedViewController: UIViewController, presentingViewController: UIViewController?, backgroundColor: UIColor) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.background.backgroundColor = backgroundColor
    }
}

// MARK: View Lifecycle
extension AlertPresentationController {
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        let alertViewController = presentedViewController as! AlertViewController
        alertViewController.resize()

        let gesture = UITapGestureRecognizer(target:self, action: #selector(AlertPresentationController.dismiss))
        background.addGestureRecognizer(gesture)
    }
}

// MARK: Presentation
extension AlertPresentationController {
    override func presentationTransitionWillBegin() {
        if let containerView = containerView {
            background.alpha = 0
            background.frame = containerView.bounds
            containerView.addSubview(background)

            let transitionCoordinator = presentingViewController.transitionCoordinator
            transitionCoordinator?.animate(alongsideTransition: { _ in
                self.background.alpha = 1
                }, completion: .none)
            if let presentedView = presentedView {
                containerView.addSubview(presentedView)
            }
        }
    }

    override func dismissalTransitionWillBegin() {
        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { _ in
            self.background.alpha = 0
        }, completion: .none)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            background.removeFromSuperview()
        }
    }
}

extension AlertPresentationController {
    func dismiss() {
        let alertViewController = presentedViewController as! AlertViewController
        if alertViewController.dismissable {
            presentedViewController.dismiss(animated: true, completion: .none)
        }
    }
}
