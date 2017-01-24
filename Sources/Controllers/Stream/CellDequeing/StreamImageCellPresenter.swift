////
///  StreamImageCellPresenter.swift
//

import Foundation

struct StreamImageCellPresenter {

    static func preventImageStretching(_ cell: StreamImageCell, attachmentWidth: Int, columnWidth: CGFloat, leftMargin: CGFloat) {
        let width = CGFloat(attachmentWidth)
        if width < columnWidth - leftMargin {
            cell.imageRightConstraint.constant = columnWidth - width - leftMargin
        }
        else {
            cell.imageRightConstraint.constant = 0
        }
    }

    static func calculateStreamImageMargin(
        _ cell: StreamImageCell,
        imageRegion: ImageRegion,
        streamCellItem: StreamCellItem) -> StreamImageCell.StreamImageMargin
    {
        // Repost specifics
        if imageRegion.isRepost == true {
            return .repost
        }
        else if streamCellItem.jsonable is ElloComment {
            return .comment
        }
        else {
            return .post
        }
    }

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? StreamImageCell,
            let imageRegion = streamCellItem.type.data as? ImageRegion
        else {
            return
        }

        var attachmentToLoad: Attachment?
        var imageToLoad: URL?
        var showGifInThisCell = false
        if let asset = imageRegion.asset, asset.isGif {
            if streamKind.supportsLargeImages || !asset.isLargeGif {
                attachmentToLoad = asset.optimized
                imageToLoad = asset.optimized?.url as URL?
                showGifInThisCell = true
            }
            else {
                cell.presentedImageUrl = asset.optimized?.url
                cell.isLargeImage = true
            }
            cell.isGif = true
        }

        cell.isGridView = streamKind.isGridView
        if streamKind.isGridView {
            attachmentToLoad = attachmentToLoad ?? imageRegion.asset?.gridLayoutAttachment
        }
        else {
            attachmentToLoad = attachmentToLoad ?? imageRegion.asset?.oneColumnAttachment
        }

        let imageToShow = attachmentToLoad?.image
        imageToLoad = imageToLoad ?? attachmentToLoad?.url as URL?

        let cellMargin = calculateStreamImageMargin(cell, imageRegion: imageRegion, streamCellItem: streamCellItem)
        cell.marginType = cellMargin

        if let attachmentWidth = attachmentToLoad?.width {
            let columnWidth: CGFloat = calculateColumnWidth(frameWidth: UIWindow.windowWidth(), columnCount: streamKind.columnCountFor(width: cell.frame.width))
            preventImageStretching(cell, attachmentWidth: attachmentWidth, columnWidth: columnWidth, leftMargin: cell.margin)
        }

        cell.onHeightMismatch = { actualHeight in
            streamCellItem.calculatedCellHeights.webContent = actualHeight
            streamCellItem.calculatedCellHeights.oneColumn = actualHeight
            streamCellItem.calculatedCellHeights.multiColumn = actualHeight
            postNotification(StreamNotification.UpdateCellHeightNotification, value: cell)
        }

        if let image = imageToShow, !showGifInThisCell {
            cell.setImage(image)
        }
        else if let imageURL = imageToLoad {
            cell.serverProvidedAspectRatio = StreamImageCellSizeCalculator.aspectRatioForImageRegion(imageRegion)
            cell.setImageURL(imageURL)
        }
        else if let imageURL = imageRegion.url {
            cell.isGif = imageURL.hasGifExtension
            cell.setImageURL(imageURL)
        }

        cell.buyButtonURL = imageRegion.buyButtonURL
        cell.layoutIfNeeded()
    }
}
