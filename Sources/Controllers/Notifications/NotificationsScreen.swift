////
///  NotificationsScreen.swift
//

@objc
protocol NotificationsScreenDelegate {
    func activatedCategory(_ filter: String)
}

class NotificationsScreen: UIView {

    fileprivate let filterAllButton = NotificationsScreen.filterButton(title: "All")
    fileprivate let filterCommentsButton = NotificationsScreen.filterButton(image: .comments)
    fileprivate let filterMentionButton = NotificationsScreen.filterButton(title: "@")
    fileprivate let filterHeartButton = NotificationsScreen.filterButton(image: .heart)
    fileprivate let filterRepostButton = NotificationsScreen.filterButton(image: .repost)
    fileprivate let filterInviteButton = NotificationsScreen.filterButton(image: .invite)

    fileprivate class func filterButton() -> UIButton {
        let button = UIButton()
        button.titleLabel?.font = UIFont.defaultFont()
        button.setTitleColor(UIColor.white, for: .selected)
        button.setTitleColor(UIColor.greyA(), for: .normal)
        button.setBackgroundImage(UIImage.imageWithColor(UIColor.black), for: .selected)
        button.setBackgroundImage(UIImage.imageWithColor(UIColor.greyE5()), for: .normal)
        return button
    }
    fileprivate class func filterButton(image interfaceImage: InterfaceImage) -> UIButton {
        let button = filterButton()
        button.setImage(interfaceImage.normalImage, for: .normal)
        button.setImage(interfaceImage.whiteImage, for: .selected)
        button.imageView!.contentMode = .scaleAspectFit
        return button
    }
    fileprivate class func filterButton(title: String) -> UIButton {
        let button = filterButton()
        button.setTitle(title, for: .normal)
        return button
    }


    weak var delegate: NotificationsScreenDelegate?
    let filterBar = NotificationsFilterBar()
    let streamContainer = UIView()

    var navBarVisible = true

    override init(frame: CGRect) {

        filterMentionButton.titleLabel!.font = UIFont.defaultFont(16)

        super.init(frame: frame)
        backgroundColor = UIColor.white
        self.addSubview(streamContainer)

        for (button, action) in [
            (filterAllButton, "allButtonTapped:"),
            (filterCommentsButton, "commentsButtonTapped:"),
            (filterMentionButton, "mentionButtonTapped:"),
            (filterHeartButton, "heartButtonTapped:"),
            (filterRepostButton, "repostButtonTapped:"),
            (filterInviteButton, "inviteButtonTapped:"),
        ] {
            filterBar.addSubview(button)
            button.addTarget(self, action: Selector(action), for: .touchUpInside)
        }
        filterBar.selectButton(filterAllButton)
        self.addSubview(filterBar)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        positionFilterBar()
        streamContainer.frame = self.bounds.fromTop()
            .with(height: self.frame.height)
    }

    func allButtonTapped(_ sender: UIButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.all.rawValue)
    }

    func commentsButtonTapped(_ sender: UIButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.comments.rawValue)
    }

    func mentionButtonTapped(_ sender: UIButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.mention.rawValue)
    }

    func heartButtonTapped(_ sender: UIButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.heart.rawValue)
    }

    func repostButtonTapped(_ sender: UIButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.repost.rawValue)
    }

    func inviteButtonTapped(_ sender: UIButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.relationship.rawValue)
    }
}


// MARK: Filter Bar
extension NotificationsScreen {

    func selectFilterButton(_ filterType: NotificationFilterType) {
        switch filterType {
        case .all: filterBar.selectButton(filterAllButton)
        case .comments: filterBar.selectButton(filterCommentsButton)
        case .mention: filterBar.selectButton(filterMentionButton)
        case .heart: filterBar.selectButton(filterHeartButton)
        case .repost: filterBar.selectButton(filterRepostButton)
        case .relationship: filterBar.selectButton(filterInviteButton)
        }
    }

    func animateNavigationBar(visible: Bool) {
        navBarVisible = visible
        animate {
            self.positionFilterBar()
        }
//        UIApplication.shared.
//        UIApplication.shared.setStatusBarHidden(!visible, with: .none)
    }

    fileprivate func positionFilterBar() {
        filterBar.frame = self.bounds.with(height: NotificationsFilterBar.Size.height)
        if navBarVisible {
            filterBar.frame.origin.y = 0
        }
        else {
            filterBar.frame.origin.y = -NotificationsFilterBar.Size.height
        }
    }

}
