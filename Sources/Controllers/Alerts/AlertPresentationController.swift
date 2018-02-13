////
///  AlertPresentationController.swift
//

class AlertPresentationController: UIPresentationController {
    private let backgroundView = UIView()

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        backgroundView.backgroundColor = .dimmedModalBackground

        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        backgroundView.addGestureRecognizer(gesture)
    }
}

// MARK: View Lifecycle
extension AlertPresentationController {
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        if let alertViewController = presentedViewController as? AlertViewController {
            alertViewController.resize()
        }
        else if
            let containerView = containerView,
            let presentedView = presentedView
        {
            backgroundView.frame = containerView.bounds
            presentedView.frame = containerView.bounds
        }
    }
}

// MARK: Presentation
extension AlertPresentationController {
    override func presentationTransitionWillBegin() {
        guard
            let containerView = containerView,
            let presentedView = presentedView
        else { return }

        containerView.addSubview(backgroundView)
        containerView.addSubview(presentedView)

        backgroundView.alpha = 0
        backgroundView.frame = containerView.bounds

        presentedView.frame = containerView.bounds

        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { _ in
            presentedView.frame = containerView.bounds
            presentedView.alpha = 1
            self.backgroundView.alpha = 1
        }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { _ in
            self.backgroundView.alpha = 0
        }, completion: nil)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            backgroundView.removeFromSuperview()
        }
    }
}

extension AlertPresentationController {
    @objc
    func dismiss() {
        if let alertViewController = presentedViewController as? AlertViewController,
            !alertViewController.isDismissable { return }

        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
