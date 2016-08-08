////
///  CreateConversationViewController.swift
//

public class CreateConversationViewController: StreamableViewController {

    var screen: ConversationsScreen { return self.view as! ConversationsScreen }
    var rightItem: UIBarButtonItem!
    var selectedUsers: [User] = []

    required public init() {
        super.init(nibName: nil, bundle: nil)

        title = InterfaceString.CreateConversation.Title
        elloNavigationItem.title = title
        let leftItem = UIBarButtonItem.backChevronWithTarget(self, action: #selector(backTapped(_:)))

        elloNavigationItem.leftBarButtonItems = [leftItem]


        rightItem = UIBarButtonItem(image: .Pencil, target: self, action: #selector(createConversationTapped(_:)))
        rightItem.enabled = false
        elloNavigationItem.rightBarButtonItems = [rightItem]
        elloNavigationItem.fixNavBarItemPadding()

        streamViewController.streamKind = .CreateConversation
        streamViewController.conversationDelegate = self
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

extension CreateConversationViewController {
    func createConversationTapped(target: UIBarButtonItem) {
        MessengerService().createConversation(selectedUsers)
    }
}

extension CreateConversationViewController: ConversationDelegate {
    public func userSelected(user: User) {
        print("user selected")
        if let index = selectedUsers.indexOf(user) {
            selectedUsers.removeAtIndex(index)
        }
        else {
            selectedUsers.append(user)
        }
        rightItem.enabled = selectedUsers.count > 0
    }
}
