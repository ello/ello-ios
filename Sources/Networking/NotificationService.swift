////
///  NotificationService.swift
//

import PromiseKit


class NotificationService {

    init() {}

    func loadAnnouncements() -> Promise<Announcement?> {
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(
                .announcements,
                success: { (data, responseConfig) in
                    if let results = data as? Announcement {
                        fulfill(results)
                    }
                    else if data as? String == "" {
                        fulfill(nil)
                    }
                    else {
                        let error = NSError.uncastableJSONAble()
                        reject(error)
                    }
                },
                failure: { error, _ in
                    reject(error)
                }
            )
        }
    }

    func markAnnouncementAsRead(_ announcement: Announcement) -> Promise<Announcement> {
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(.markAnnouncementAsRead,
                success: { _ in
                    fulfill(announcement)
                },
                failure: { error, _ in
                    reject(error)
                }
            )
        }
    }

}
