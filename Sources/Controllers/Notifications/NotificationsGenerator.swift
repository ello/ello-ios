////
///  NotificationsGenerator.swift
//

import PromiseKit


final class NotificationsGenerator: StreamGenerator {
    var currentUser: User?
    var streamKind: StreamKind

    private var notificationActivities: [Activity] = []
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
            notificationActivities = []
        }
        else {
            setPlaceHolders()
        }

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

    func loadNotifications() {
        StreamService().loadStream(streamKind: streamKind)
            .done { response in
                guard self.loadingToken.isValidInitialPageLoadingToken(self.localToken) else { return }

                switch response {
                case let .jsonables(jsonables, responseConfig):
                    guard
                        let notificationActivities = jsonables as? [Activity]
                    else { return }

                    self.notificationActivities = notificationActivities
                    self.destination?.setPagingConfig(responseConfig: responseConfig)

                    self.loadExtraNotificationContent(notificationActivities)
                        .done { _ in
                            let notificationItems = self.parse(jsonables: notificationActivities)
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
                        .ignoreErrors()
                case .empty:
                    let noContentItem = StreamCellItem(type: .emptyStream(height: 282))
                    self.destination?.replacePlaceholder(type: .notifications, items: [noContentItem]) {
                        self.destination?.isPagingEnabled = false
                    }
                }
            }
            .catch { _ in
                self.destination?.primaryModelNotFound()
            }
    }

    private func loadExtraNotificationContent(_ notificationActivities: [Activity]) -> Guarantee<Void> {
        let (promise, fulfill) = Guarantee<Void>.pending()
        let (afterAll, done) = afterN {
            fulfill(Void())
        }
        for activity in notificationActivities {
            guard let submission = activity.subject as? ArtistInviteSubmission, submission.artistInvite == nil else { continue }

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
