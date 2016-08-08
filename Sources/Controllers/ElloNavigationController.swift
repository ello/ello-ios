////
///  ElloNavigationController.swift
//

public let ExternalWebNotification = TypedNotification<String>(name: "ExternalWebNotification")

public class ElloNavigationController: UINavigationController {

    var interactionController: UIPercentDrivenInteractiveTransition?
    var postChangedNotification: NotificationObserver?
    var relationshipChangedNotification: NotificationObserver?
    var rootViewControllerName: String?
    public var currentUser: User? {
        didSet { didSetCurrentUser() }
    }

    var backGesture: UIScreenEdgePanGestureRecognizer?

    override public var tabBarItem: UITabBarItem? {
        get { return childViewControllers.first?.tabBarItem ?? super.tabBarItem }
        set { self.tabBarItem = newValue }
    }

    enum RootViewControllers: String {
        case Notifications = "NotificationsViewController"
        case Profile = "ProfileViewController"
        case Omnibar = "OmnibarViewController"
        case Discover = "DiscoverViewController"
        case Conversations = "ConversationsViewController"

        func controllerInstance(user: User) -> BaseElloViewController {
            switch self {
            case Notifications: return NotificationsViewController()
            case Profile: return ProfileViewController(user: user)
            case Omnibar:
                let vc = OmnibarViewController()
                vc.canGoBack = false
                return vc
            case Discover: return DiscoverViewController()
            case Conversations: return ConversationsViewController()
            }
        }
    }

    public func setProfileData(currentUser: User) {
        postNotification(SettingChangedNotification, value: currentUser)
        self.currentUser = currentUser
        if self.viewControllers.count == 0 {
            if let rootViewControllerName = rootViewControllerName {
                if let controller = RootViewControllers(rawValue:rootViewControllerName)?.controllerInstance(currentUser) {
                    controller.currentUser = currentUser
                    self.viewControllers = [controller]
                }
            }
        }
    }

    func didSetCurrentUser() {
        if self.viewControllers.count > 0 {
            for controller in self.viewControllers {
                if let controller = controller as? ControllerThatMightHaveTheCurrentUser {
                    controller.currentUser = currentUser
                }
            }
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarHidden(true, animated: false)

        delegate = self

        backGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(ElloNavigationController.handleBackGesture(_:)))
        if let backGesture = backGesture {
            self.view.addGestureRecognizer(backGesture)
        }

        postChangedNotification = NotificationObserver(notification: PostChangedNotification) { (post, change) in
            switch change {
            case .Delete:
                var keepers = [UIViewController]()
                for controller in self.childViewControllers {
                    if let postDetailVC = controller as? PostDetailViewController {
                        if let postId = postDetailVC.post?.id where postId != post.id {
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
            case .Block:
                var keepers = [UIViewController]()
                for controller in self.childViewControllers {
                    if let userStreamVC = controller as? ProfileViewController {
                        if let userId = userStreamVC.user?.id where userId != user.id {
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

    func handleBackGesture(gesture: UIScreenEdgePanGestureRecognizer) {
        let percentThroughView = gesture.percentageThroughView(gesture.edges)

        switch gesture.state {
        case .Began:
            interactionController = UIPercentDrivenInteractiveTransition()
            topViewController?.backGestureAction()
        case .Changed:
            interactionController?.updateInteractiveTransition(percentThroughView)
        case .Ended, .Cancelled:
            if percentThroughView > 0.5 {
                interactionController?.finishInteractiveTransition()
            } else {
                interactionController?.cancelInteractiveTransition()
            }
            interactionController = nil
        default:
            interactionController = nil
        }
    }

}

extension ElloNavigationController: UIGestureRecognizerDelegate {

    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

private let throttledTracker = debounce(0.1)
extension ElloNavigationController: UINavigationControllerDelegate {

    public func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        backGesture?.edges = viewController.backGestureEdges

        throttledTracker {
            Tracker.sharedTracker.screenAppeared(viewController)
        }
    }

    public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        switch operation {
        case .Push: return ForwardAnimator()
        case .Pop: return BackAnimator()
        default: return .None
        }
    }

    public func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

}
