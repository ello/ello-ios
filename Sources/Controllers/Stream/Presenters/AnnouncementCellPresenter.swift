////
///  AnnouncementCellPresenter.swift
//

struct AnnouncementCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? AnnouncementCell,
            let announcement = streamCellItem.jsonable as? Announcement
        else { return }

        var config = AnnouncementCell.Config()
        config.title = announcement.header
        config.body = announcement.body
        config.callToAction = announcement.ctaCaption
        config.imageURL = announcement.imageURL
        config.isStaffPreview = announcement.isStaffPreview
        cell.config = config
    }
}
