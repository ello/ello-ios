////
///  NotificationService.swift
//

import PromiseKit


class NotificationService {

    func loadAnnouncements() -> Promise<Announcement?> {
        return ElloProvider.shared.request(.announcements)
            .map { data, _ -> Announcement? in
                if let results = data as? Announcement {
                    return results
                }
                else if data as? String == "" {
                    return nil
                }
                else {
                    throw NSError.uncastableModel()
                }
            }
    }

    func markAnnouncementAsRead(_ announcement: Announcement) -> Promise<Announcement> {
        return ElloProvider.shared.request(.markAnnouncementAsRead)
            .map { _ -> Announcement in
                return announcement
            }
    }

}
