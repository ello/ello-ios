////
///  NotificationCellPresenter.swift
//

struct NotificationCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?
    ) {
        guard
            let cell = cell as? NotificationCell,
            let notification = streamCellItem.jsonable as? Notification
        else { return }

        cell.onWebContentReady { webView in
            if let actualHeight = webView.windowContentSize()?.height,
                let webContent = streamCellItem.calculatedCellHeights.webContent,
                ceil(actualHeight) != ceil(webContent)
            {
                NotificationCellSizeCalculator.assignTotalHeight(
                    actualHeight,
                    item: streamCellItem,
                    cellWidth: cell.frame.width
                )
                postNotification(
                    StreamNotification.UpdateCellHeightNotification,
                    value: streamCellItem
                )
            }
        }

        cell.onHeightMismatch = { height in
            streamCellItem.calculatedCellHeights.oneColumn = height
            streamCellItem.calculatedCellHeights.multiColumn = height
            postNotification(StreamNotification.UpdateCellHeightNotification, value: streamCellItem)
        }

        cell.title = NotificationAttributedTitle.from(notification: notification)
        cell.createdAt = notification.createdAt
        cell.user = notification.author
        cell.canReplyToComment = notification.canReplyToComment
        cell.canBackFollow = notification.canBackFollow
        cell.post = notification.activity.subject as? Post
        cell.comment = notification.activity.subject as? ElloComment
        cell.submission = notification.activity.subject as? ArtistInviteSubmission
        cell.messageHtml = notification.textRegion?.content

        if let imageRegion = notification.imageRegion {
            cell.mode = .image
            let aspectRatio = StreamImageCellSizeCalculator.aspectRatioForImageRegion(imageRegion)
            var imageURL: URL?
            if let asset = imageRegion.asset, !asset.isGif {
                imageURL = asset.optimized?.url
            }
            else if let hdpiURL = imageRegion.asset?.hdpi?.url {
                imageURL = hdpiURL
            }
            else {
                imageURL = imageRegion.url
            }
            cell.aspectRatio = aspectRatio
            cell.imageURL = imageURL
            cell.buyButtonVisible = (imageRegion.buyButtonURL != nil)
        }
    }

}
