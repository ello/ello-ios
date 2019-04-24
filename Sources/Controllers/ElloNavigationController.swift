////
///  ElloNavigationController.swift
//

let ExternalWebNotification = TypedNotification<String>(name: "ExternalWebNotification")
let InternalWebNotification = TypedNotification<String>(name: "InternalWebNotification")

class ElloNavigationController: UINavigationController, ControllerThatMightHaveTheCurrentUser {

    var interactionController: UIPercentDrivenInteractiveTransition?
    var postChangedNotification: NotificationObserver?
    var relationshipChangedNotification: NotificationObserver?
    var rootViewControllerName: String?
    var currentUser: User? {
        didSet { didSetCurrentUser() }
    }

    var backGesture: UIScreenEdgePanGestureRecognizer?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return visibleViewController?.preferredStatusBarStyle ?? .default
    }

    func didSetCurrentUser() {
        for controller in self.viewControllers {
            guard let controller = controller as? ControllerThatMightHaveTheCurrentUser else { return }
            controller.currentUser = currentUser
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarHidden(true, animated: false)

        delegate = self

        backGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(ElloNavigationController.handleBackGesture(_:)))
        if let backGesture = backGesture {
            self.view.addGestureRecognizer(backGesture)
        }

        postChangedNotification = NotificationObserver(notification: PostChangedNotification) { (post, change) in
            switch change {
            case .delete:
                var keepers = [UIViewController]()
                for controller in self.children {
                    if let postDetailVC = controller as? PostDetailViewController {
                        if let postId = postDetailVC.post?.id, postId != post.id {
                            keepers.append(controller)
                        }
                    }
                    else {
                        keepers.append(controller)
                    }
                }
                self.setViewControllers(keepers, animated: true)
            default: break
            }
        }

        relationshipChangedNotification = NotificationObserver(notification: RelationshipChangedNotification) { user in
            switch user.relationshipPriority {
            case .block:
                var keepers = [UIViewController]()
                for controller in self.children {
                    if let userStreamVC = controller as? ProfileViewController {
                        if let userId = userStreamVC.user?.id, userId != user.id {
                            keepers.append(controller)
                        }
                    }
                    else {
                        keepers.append(controller)
                    }
                }
                self.setViewControllers(keepers, animated: true)
            default:
                break
            }
        }
    }

    @objc
    func handleBackGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
        let percentThroughView = gesture.percentageThroughView(gesture.edges)

        switch gesture.state {
        case .began:
            interactionController = UIPercentDrivenInteractiveTransition()
            topViewController?.backGestureAction()
        case .changed:
            interactionController?.update(percentThroughView)
        case .ended, .cancelled:
            if percentThroughView > 0.5 {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            interactionController = nil
        default:
            interactionController = nil
        }
    }

}

extension ElloNavigationController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

extension ElloNavigationController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        backGesture?.edges = viewController.backGestureEdges
    }

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        switch operation {
        case .push: return ForwardAnimator()
        case .pop: return BackAnimator()
        default: return .none
        }
    }

    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

}
