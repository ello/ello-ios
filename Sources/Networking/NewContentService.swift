////
///  NewContentService.swift
//

import SwiftyUserDefaults
import PromiseKit


struct NewContentNotifications {
    static let newAnnouncements = TypedNotification<()>(name: "NewAnnouncementsNotification")
    static let newNotifications = TypedNotification<()>(name: "NewNotificationsNotification")
    static let newFollowingContent = TypedNotification<()>(name: "NewFollowingContentNotification")
    static let reloadFollowingContent = TypedNotification<()>(name: "ReloadFollowingContentNotification")
    static let reloadNotifications = TypedNotification<()>(name: "ReloadNotificationsNotification")
    static let pause = TypedNotification<()>(name: "NewContentService-pause")
    static let resume = TypedNotification<()>(name: "NewContentService-resume")
}


class NewContentService {
    fileprivate var timer: Timer?
    fileprivate var pauseCount = 0
    fileprivate var pauseObserver: NotificationObserver?
    fileprivate var resumeObserver: NotificationObserver?
    fileprivate var postCreatedObserver: NotificationObserver?

    init() {
        pauseObserver = NotificationObserver(notification: NewContentNotifications.pause) { [weak self] _ in
            self?.pauseCount += 1
        }
        resumeObserver = NotificationObserver(notification: NewContentNotifications.resume) { [weak self] _ in
            self?.pauseCount -= 1
        }
        postCreatedObserver = NotificationObserver(notification: PostChangedNotification) { [weak self] (post, change) in
            if change == .create {
                self?.updateCreatedAt([post], streamKind: .following)
            }
        }
    }
}

extension NewContentService {

    func startPolling() {
        checkForNewContent()
    }

    private func restartPolling() {
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(NewContentService.checkForNewContent), userInfo: nil, repeats: false)
    }

    func stillPolling() -> Bool {
        return timer != nil
    }

    func stopPolling() {
        timer?.invalidate()
    }

    @objc
    func checkForNewContent() {
        guard pauseCount == 0 else { return }

        stopPolling()
        let check1 = checkForNewNotifications()
        let check2 = checkForNewAnnouncements()
        let check3 = checkForNewFollowingContent()
        when(resolved: [check1, check2, check3])
            .always { _ in
                guard self.stillPolling() else { return }
                self.restartPolling()
            }
    }

    func updateCreatedAt(_ jsonables: [JSONAble], streamKind: StreamKind) {
        guard let storedKey = streamKind.lastViewedCreatedAtKey else { return }

        let old = Date(timeIntervalSince1970: 0)
        let new = newestDate(jsonables)
        let storedDate = GroupDefaults[storedKey].date ?? old
        let mostRecent = new > storedDate ? new : storedDate
        GroupDefaults[storedKey] = mostRecent
    }
}

private extension NewContentService {

    func newestDate(_ jsonables: [JSONAble]) -> Date {
        let old = Date(timeIntervalSince1970: 0)
        return jsonables.reduce(old) {
            (date, jsonable) -> Date in
            if let post = jsonable as? Post {
                return post.createdAt as Date > date ? post.createdAt as Date : date
            }
            else if let notification = jsonable as? Notification {
                return notification.createdAt as Date > date ? notification.createdAt as Date : date
            }
            else if let activity = jsonable as? Activity {
                return activity.createdAt as Date > date ? activity.createdAt as Date : date
            }
            return date
        }
    }

    func checkForNewNotifications() -> Promise<Void> {
        let storedKey = StreamKind.notifications(category: nil).lastViewedCreatedAtKey!
        let storedDate = GroupDefaults[storedKey].date

        return ElloProvider.shared.request(.notificationsNewContent(createdAt: storedDate))
            .thenFinally { response in
                guard
                    let statusCode = response.1.statusCode,
                    statusCode == 204
                    else { return }

                postNotification(NewContentNotifications.newNotifications, value: ())
            }
    }

    func checkForNewAnnouncements() -> Promise<Void> {
        let storedKey = StreamKind.announcements.lastViewedCreatedAtKey!
        let storedDate = GroupDefaults[storedKey].date

         return ElloProvider.shared.request(.announcementsNewContent(createdAt: storedDate))
             .thenFinally { response in
                guard
                    let statusCode = response.1.statusCode,
                    statusCode == 204
                else { return }

                postNotification(NewContentNotifications.newAnnouncements, value: ())
             }
    }

    func checkForNewFollowingContent() -> Promise<Void> {
        let storedKey = StreamKind.following.lastViewedCreatedAtKey!
        let storedDate = GroupDefaults[storedKey].date

        return ElloProvider.shared.request(.followingNewContent(createdAt: storedDate))
            .thenFinally { response in
                let responseConfig = response.1
                if let lastModified = responseConfig.lastModified {
                    GroupDefaults[storedKey] = lastModified.toDate(HTTPDateFormatter)
                }

                if let statusCode = responseConfig.statusCode, statusCode == 204 {
                    postNotification(NewContentNotifications.newFollowingContent, value: ())
                }
            }
    }
}
