////
///  StreamTextCellPresenter.swift
//

struct StreamTextCellPresenter {
    static let commentMargin = CGFloat(60)
    static let postMargin = CGFloat(15)
    static let repostMargin = CGFloat(30)

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        if let cell = cell as? StreamTextCell {
            cell.onWebContentReady { webView in
                if let actualHeight = webView.windowContentSize()?.height, actualHeight != streamCellItem.calculatedCellHeights.webContent {
                    streamCellItem.calculatedCellHeights.webContent = actualHeight
                    streamCellItem.calculatedCellHeights.oneColumn = actualHeight
                    streamCellItem.calculatedCellHeights.multiColumn = actualHeight
                    postNotification(StreamNotification.UpdateCellHeightNotification, value: cell)
                }
            }

            var isRepost = false
            if let textRegion = streamCellItem.type.data as? TextRegion {
                isRepost = textRegion.isRepost
                let content = textRegion.content
                let html = StreamTextCellHTML.postHTML(content)
                cell.webView.loadHTMLString(html, baseURL: URL(string: "/"))
            }
            // Repost specifics
            if isRepost == true {
                cell.leadingConstraint.constant = 30.0
                cell.showBorder()
            }
            else if streamCellItem.jsonable is ElloComment {
                cell.leadingConstraint.constant = commentMargin
            }
            else {
                cell.leadingConstraint.constant = postMargin
            }
        }
    }

}
