////
///  NotificationCellPresenter.swift
//

struct NotificationCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? NotificationCell,
            let notification = streamCellItem.jsonable as? Notification
        else { return }

        cell.onWebContentReady { webView in
            if let actualHeight = webView.windowContentSize()?.height, actualHeight != streamCellItem.calculatedCellHeights.webContent {
                StreamNotificationCellSizeCalculator.assignTotalHeight(actualHeight, cellItem: streamCellItem, cellWidth: cell.frame.width)
                postNotification(StreamNotification.UpdateCellHeightNotification, value: cell)
            }
        }
        cell.onHeightMismatch = { height in
            streamCellItem.calculatedCellHeights.oneColumn = height
            streamCellItem.calculatedCellHeights.multiColumn = height
            postNotification(StreamNotification.UpdateCellHeightNotification, value: cell)
        }

        cell.title = notification.attributedTitle
        cell.createdAt = notification.createdAt
        cell.user = notification.author
        cell.canReplyToComment = notification.canReplyToComment
        cell.canBackFollow = notification.canBackFollow
        cell.post = notification.activity.subject as? Post
        cell.comment = notification.activity.subject as? ElloComment
        cell.messageHtml = notification.textRegion?.content

        if let imageRegion = notification.imageRegion {
            let aspectRatio = StreamImageCellSizeCalculator.aspectRatioForImageRegion(imageRegion)
            var imageURL: URL?
            if let asset = imageRegion.asset, !asset.isGif {
                imageURL = asset.optimized?.url as URL?
            }
            else if let hdpiURL = imageRegion.asset?.hdpi?.url{
                imageURL = hdpiURL as URL
            }
            else {
                imageURL = imageRegion.url as URL?
            }
            cell.aspectRatio = aspectRatio
            cell.imageURL = imageURL
            cell.buyButtonVisible = (imageRegion.buyButtonURL != nil)
        }
    }

}
