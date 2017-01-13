////
///  NotificationsGenerator.swift
//

final class NotificationsGenerator: StreamGenerator {
    var currentUser: User?
    var streamKind: StreamKind

    fileprivate var notifications: [Activity] = []
    fileprivate var announcements: [Announcement] = []
    fileprivate var hasNotifications: Bool?

    weak var destination: StreamDestination?

    fileprivate var localToken: String = ""
    fileprivate var loadingToken = LoadingToken()

    init(
        currentUser: User?,
        streamKind: StreamKind,
        destination: StreamDestination?
        ) {
        self.currentUser = currentUser
        self.streamKind = streamKind
        self.destination = destination
        self.localToken = loadingToken.resetInitialPageLoadingToken()
    }

    func load(reload: Bool = false) {
        localToken = loadingToken.resetInitialPageLoadingToken()

        if reload {
            announcements = []
            notifications = []
        }

        setPlaceHolders()
        loadAnnouncements()
        loadNotifications()
    }

    func reloadAnnouncements() {
        loadAnnouncements()
    }

    func setPlaceHolders() {
        destination?.setPlaceholders(items: [
            StreamCellItem(type: .placeholder, placeholderType: .announcements),
            StreamCellItem(type: .placeholder, placeholderType: .notifications),
        ])
    }

    func markAnnouncementAsRead(_ announcement: Announcement) {
        NotificationService().markAnnouncementAsRead(announcement)
            .onSuccess { [weak self] _ in
                self?.announcements = []
            }
            .onFail { _ in }
    }

    func loadAnnouncements() {
        guard case let .notifications(category) = streamKind, category == nil else {
            compareAndUpdateAnnouncements([])
            return
        }

        NotificationService().loadAnnouncements()
            .onSuccess { [weak self] announcement in
                guard let `self` = self else { return }
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else { return }

                self.compareAndUpdateAnnouncements([announcement])
            }
            .onFail { [weak self] _ in
                self?.compareAndUpdateAnnouncements([])
            }
    }

    fileprivate func compareAndUpdateAnnouncements(_ newAnnouncements: [Announcement]) {
        guard !announcementsAreSame(newAnnouncements) else { return }

        self.announcements = newAnnouncements
        let announcementItems = StreamCellItemParser().parse(newAnnouncements, streamKind: .announcements, currentUser: self.currentUser)
        self.destination?.replacePlaceholder(type: .announcements, items: announcementItems) {}
    }

    func announcementsAreSame(_ newAnnouncements: [Announcement]) -> Bool {
        return announcements.count == newAnnouncements.count && announcements.enumerated().all({ (index, announcement) in
            return announcement.id == newAnnouncements[index].id
        })
    }

    func loadNotifications() {
        StreamService().loadStream(
            streamKind: streamKind,
            success: { [weak self] (jsonables, responseConfig) in
                guard let `self` = self else { return }
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else { return }
                guard let notifications = jsonables as? [Activity] else { return }

                self.notifications = notifications
                // setting primaryJSONAble also triggers the "done loading" code
                self.destination?.setPrimary(jsonable: JSONAble(version: JSONAbleVersion))
                self.destination?.setPagingConfig(responseConfig: responseConfig)

                let notificationItems = self.parse(jsonables: notifications)
                if notificationItems.count == 0 {
                    let noContentItem = StreamCellItem(type: .emptyStream(height: 282))
                    self.hasNotifications = false
                    self.destination?.replacePlaceholder(type: .notifications, items: [noContentItem]) {
                        self.destination?.pagingEnabled = false
                    }
                }
                else {
                    self.hasNotifications = true
                    self.destination?.replacePlaceholder(type: .notifications, items: notificationItems) {
                        self.destination?.pagingEnabled = true
                    }
                }
            },
            failure: { [weak self] _ in
                self?.destination?.primaryJSONAbleNotFound()
            },
            noContent: { [weak self] in
                guard let `self` = self else { return }
                let noContentItem = StreamCellItem(type: .emptyStream(height: 282))
                self.destination?.setPrimary(jsonable: JSONAble(version: JSONAbleVersion))
                self.destination?.replacePlaceholder(type: .notifications, items: [noContentItem]) {
                    self.destination?.pagingEnabled = false
                }
            }
        )
    }
}
