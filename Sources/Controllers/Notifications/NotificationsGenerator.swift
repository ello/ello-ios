////
///  NotificationsGenerator.swift
//

import PromiseKit


final class NotificationsGenerator: StreamGenerator {
    var currentUser: User?
    var streamKind: StreamKind

    private var before: String?
    private var notifications: [Notification] = []
    private var announcements: [Announcement] = []
    private var hasNotifications: Bool?

    weak var destination: StreamDestination?

    private var localToken: String = ""
    private var loadingToken = LoadingToken()

    init(currentUser: User?, streamKind: StreamKind, destination: StreamDestination) {
        self.currentUser = currentUser
        self.streamKind = streamKind
        self.destination = destination
    }

    func load(reload: Bool = false) {
        localToken = loadingToken.resetInitialPageLoadingToken()

        if reload {
            announcements = []
            notifications = []
        }
        else {
            setPlaceHolders()
        }

        loadAnnouncements()
        loadInitialNotifications()
    }

    func loadInitialNotifications() {
        loadNotifications(before: nil)
            .done { notifications in
                self.notifications = notifications

                if notifications.isEmpty {
                    let noContentItem = StreamCellItem(type: .emptyStream(height: 282))
                    self.destination?.replacePlaceholder(type: .notifications, items: [noContentItem]) {
                        self.destination?.isPagingEnabled = false
                    }
                }
                else {
                    self.loadExtraNotificationContent(notifications)
                        .done { _ in
                            let notificationItems = self.parse(jsonables: notifications)
                            if notificationItems.count == 0 {
                                let noContentItem = StreamCellItem(type: .emptyStream(height: 282))
                                self.hasNotifications = false
                                self.destination?.replacePlaceholder(type: .notifications, items: [noContentItem]) {
                                    self.destination?.isPagingEnabled = false
                                }
                            }
                            else {
                                self.hasNotifications = true
                                self.destination?.replacePlaceholder(type: .notifications, items: notificationItems) {
                                    self.destination?.isPagingEnabled = true
                                }
                            }
                    }
                }
            }
            .catch { error in
                self.destination?.primaryModelNotFound()
        }
    }

    func loadNextPage() -> Promise<[Model]>? {
        guard let before = before else { return nil }
        return loadNotifications(before: before)
            .map { notifications -> [Model] in
                return notifications
            }
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
            .done { _ in
                self.announcements = []
            }
            .ignoreErrors()
    }

    func loadAnnouncements() {
        guard case let .notifications(category) = streamKind, category == nil else {
            compareAndUpdateAnnouncements([])
            return
        }

        NotificationService().loadAnnouncements()
            .done { announcement in
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else { return }

                if let announcement = announcement {
                    self.compareAndUpdateAnnouncements([announcement])
                }
                else {
                    self.compareAndUpdateAnnouncements([])
                }
            }
            .catch { _ in
                self.compareAndUpdateAnnouncements([])
            }
    }

    private func compareAndUpdateAnnouncements(_ newAnnouncements: [Announcement]) {
        guard !announcementsAreSame(newAnnouncements) else { return }

        self.announcements = newAnnouncements
        let announcementItems = StreamCellItemParser().parse(newAnnouncements, streamKind: .announcements, currentUser: self.currentUser)
        self.destination?.replacePlaceholder(type: .announcements, items: announcementItems)
    }

    func announcementsAreSame(_ newAnnouncements: [Announcement]) -> Bool {
        return announcements.count == newAnnouncements.count && announcements.enumerated().all({ (index, announcement) in
            return announcement.id == newAnnouncements[index].id
        })
    }

    private func loadNotifications(before: String?) -> Promise<[Notification]> {
        return API().notificationStream(before: before)
            .execute()
            .map { pageConfig, notifications in
                self.before = pageConfig.next
                self.destination?.setPagingConfig(responseConfig: ResponseConfig(pageConfig: pageConfig))
                return notifications
            }
    }

    private func loadExtraNotificationContent(_ notifications: [Notification]) -> Guarantee<Void> {
        let (promise, fulfill) = Guarantee<Void>.pending()
        let (afterAll, done) = afterN {
            fulfill(Void())
        }
        for notification in notifications {
            guard let submission = notification.subject as? ArtistInviteSubmission, submission.artistInvite == nil else { continue }

            let next = afterAll()
            ArtistInviteService().load(id: submission.artistInviteId)
                .done { artistInvite in
                    ElloLinkedStore.shared.setObject(artistInvite, forKey: submission.artistInviteId, type: .artistInvitesType)
                }
                .ensure { next() }
                .ignoreErrors()
        }
        done()
        return promise
    }
}
