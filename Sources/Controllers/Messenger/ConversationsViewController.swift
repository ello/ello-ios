////
///  ConversationsViewController.swift
//

public class ConversationsViewController: StreamableViewController {

    var screen: ConversationsScreen { return self.view as! ConversationsScreen }

    override public var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.item(.Comments) }
        set { self.tabBarItem = newValue }
    }

    required public init() {
        super.init(nibName: nil, bundle: nil)

        title = InterfaceString.Conversations.Title
        elloNavigationItem.title = title
        let rightItem = UIBarButtonItem(image: .PlusSmall, target: self, action: #selector(newConversationTapped(_:)))

        elloNavigationItem.rightBarButtonItems = [rightItem]
        elloNavigationItem.fixNavBarItemPadding()
        streamViewController.streamKind = .Conversations
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        let screen = ConversationsScreen(navigationItem: elloNavigationItem)
        self.view = screen
        viewContainer = screen.streamContainer
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
    }

    private func updateInsets() {
        updateInsets(navBar: screen.navigationBar, streamController: streamViewController)
    }

    override public func showNavBars(scrollToBottom: Bool) {
        super.showNavBars(scrollToBottom)
        positionNavBar(screen.navigationBar, visible: true, withConstraint: screen.navigationBarTopConstraint)
        updateInsets()

        if scrollToBottom {
            self.scrollToBottom(streamViewController)
        }
    }

    override public func hideNavBars() {
        super.hideNavBars()
        positionNavBar(screen.navigationBar, visible: false, withConstraint: screen.navigationBarTopConstraint)
        updateInsets()
    }

}


extension ConversationsViewController {
    func newConversationTapped(target: UIBarButtonItem) {
        let vc = CreateConversationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
