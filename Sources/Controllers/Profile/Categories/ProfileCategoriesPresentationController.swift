////
///  ProfileCategoriesPresentationController.swift
//

import UIKit

class ProfileCategoriesPresentationController: UIPresentationController {

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

// MARK: Presentation
extension ProfileCategoriesPresentationController {
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
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
