////
///  NotificationsScreen.swift
//

class NotificationsScreen: UIView, NotificationsScreenProtocol {
    private let filterAllButton = NotificationsScreen.filterButton(title: "All")
    private let filterCommentsButton = NotificationsScreen.filterButton(image: .comments)
    private let filterMentionButton = NotificationsScreen.filterButton(title: "@")
    private let filterHeartButton = NotificationsScreen.filterButton(image: .heart)
    private let filterRepostButton = NotificationsScreen.filterButton(image: .repost)
    private let filterInviteButton = NotificationsScreen.filterButton(image: .invite)

    private class func filterButton(image interfaceImage: InterfaceImage) -> UIButton {
        let button = StyledButton(style: .notification)
        button.setImage(interfaceImage.normalImage, for: .normal)
        button.setImage(interfaceImage.whiteImage, for: .selected)
        button.imageView!.contentMode = .scaleAspectFit
        return button
    }

    private class func filterButton(title: String) -> UIButton {
        let button = StyledButton(style: .notification)
        button.title = title
        return button
    }

    weak var delegate: NotificationsScreenDelegate?
    let filterBar = NotificationsFilterBar()
    let streamContainer = Container()

    var navBarVisible = true

    override init(frame: CGRect) {
        super.init(frame: frame)

        filterMentionButton.titleLabel!.font = .defaultFont(16)
        backgroundColor = .white
        addSubview(streamContainer)

        for (button, action) in [
            (filterAllButton, #selector(allButtonTapped(_:))),
            (filterCommentsButton, #selector(commentsButtonTapped(_:))),
            (filterMentionButton, #selector(mentionButtonTapped(_:))),
            (filterHeartButton, #selector(heartButtonTapped(_:))),
            (filterRepostButton, #selector(repostButtonTapped(_:))),
            (filterInviteButton, #selector(inviteButtonTapped(_:))),
        ] {
            filterBar.addSubview(button)
            button.addTarget(self, action: action, for: .touchUpInside)
        }
        filterBar.selectButton(filterAllButton)
        addSubview(filterBar)
        positionFilterBar()
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

    @objc
    func allButtonTapped(_ sender: UIButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.all.rawValue)
    }

    @objc
    func commentsButtonTapped(_ sender: UIButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.comments.rawValue)
    }

    @objc
    func mentionButtonTapped(_ sender: UIButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.mention.rawValue)
    }

    @objc
    func heartButtonTapped(_ sender: UIButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.heart.rawValue)
    }

    @objc
    func repostButtonTapped(_ sender: UIButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.repost.rawValue)
    }

    @objc
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

    private func positionFilterBar() {
        filterBar.frame = self.bounds.with(height: NotificationsFilterBar.Size.height)
        if navBarVisible {
            filterBar.frame.origin.y = 0
        }
        else {
            filterBar.frame.origin.y = -NotificationsFilterBar.Size.height
        }
    }

}
