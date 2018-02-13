////
///  DarkModalPresentationController.swift
//

class DarkModalPresentationController: UIPresentationController {

    let background: UIView = {
        let background = UIView(frame: .default)
        background.backgroundColor = UIColor.dimmedModalBackground
        return background
    }()

    init(presentedViewController: UIViewController, presentingViewController: UIViewController?, backgroundColor: UIColor) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.background.backgroundColor = backgroundColor
    }
}

// MARK: Presentation
extension DarkModalPresentationController {
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        background.alpha = 0
        background.frame = containerView.bounds
        containerView.addSubview(background)

        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { _ in
                self.background.alpha = 1
            }, completion: nil)
        if let presentedView = presentedView {
            containerView.addSubview(presentedView)
        }
    }

    override func dismissalTransitionWillBegin() {
        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { _ in
            self.background.alpha = 0
            }, completion: nil)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            background.removeFromSuperview()
        }
    }
}
