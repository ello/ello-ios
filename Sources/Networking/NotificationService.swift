////
///  NotificationService.swift
//

import PromiseKit


class NotificationService {

    func loadAnnouncements() -> Promise<Announcement?> {
        return ElloProvider.shared.request(.announcements)
            .then { data, _ -> Announcement? in
                if let results = data as? Announcement {
                    return results
                }
                else if data as? String == "" {
                    return nil
                }
                else {
                    throw NSError.uncastableJSONAble()
                }
            }
    }

    func markAnnouncementAsRead(_ announcement: Announcement) -> Promise<Announcement> {
        return ElloProvider.shared.request(.markAnnouncementAsRead)
            .then { _ -> Announcement in
                return announcement
            }
    }

}
