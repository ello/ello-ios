////
///  NotificationCellSizeCalculator.swift
//

class NotificationCellSizeCalculator: CellSizeCalculator, UIWebViewDelegate {
    private static let textViewForSizing = ElloTextView(frame: CGRect.zero, textContainer: nil)

    var notificationWidth: CGFloat {
        let notification = cellItem.jsonable as! Notification
        return NotificationCell.Size.messageHtmlWidth(
            forCellWidth: width,
            hasImage: notification.hasImage
        )
    }

    var webView: UIWebView = ElloWebView() { didSet { didSetWebView() } }

    override init(item: StreamCellItem, width: CGFloat, columnCount: Int) {
        super.init(item: item, width: width, columnCount: columnCount)
        didSetWebView()
    }

    private func didSetWebView() {
        webView.frame = CGRect(x: 0, y: 0, width: notificationWidth, height: 0)
        webView.delegate = self
    }

    override func process() {
        guard let notification = cellItem.jsonable as? Notification,
            let textRegion = notification.textRegion
        else {
            assignCellHeight(nil)
            return
        }

        let content = textRegion.content
        let strippedContent = content.stripHtmlImgSrc()
        let html = StreamTextCellHTML.postHTML(strippedContent)
        webView.loadHTMLString(html, baseURL: URL(string: "/"))
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        let webContentHeight = webView.windowContentSize()?.height ?? 0
        assignCellHeight(webContentHeight)
    }

    private func assignCellHeight(_ webContentHeight: CGFloat?) {
        NotificationCellSizeCalculator.assignTotalHeight(
            webContentHeight,
            item: cellItem,
            cellWidth: width
        )
        finish()
    }

    class func assignTotalHeight(
        _ webContentHeight: CGFloat?,
        item: StreamCellItem,
        cellWidth: CGFloat
    ) {
        let notification = item.jsonable as! Notification
        textViewForSizing.attributedText = NotificationAttributedTitle.from(
            notification: notification
        )
        let titleWidth = NotificationCell.Size.messageHtmlWidth(
            forCellWidth: cellWidth,
            hasImage: notification.hasImage
        )
        let titleSize = textViewForSizing.sizeThatFits(
            CGSize(width: titleWidth, height: .greatestFiniteMagnitude)
        )
        var totalTextHeight = ceil(titleSize.height)
        totalTextHeight += NotificationCell.Size.CreatedAtFixedHeight

        if let webContentHeight = webContentHeight, webContentHeight > 0 {
            totalTextHeight += webContentHeight + NotificationCell.Size.WebHeightCorrection
                + NotificationCell.Size.InnerMargin
        }

        if notification.canReplyToComment || notification.canBackFollow {
            totalTextHeight += NotificationCell.Size.ButtonHeight
                + NotificationCell.Size.InnerMargin
        }

        let totalImageHeight = NotificationCell.Size.imageHeight(
            imageRegion: notification.imageRegion
        )
        var height = max(totalTextHeight, totalImageHeight)

        height += 2 * NotificationCell.Size.SideMargins
        if let webContentHeight = webContentHeight {
            item.calculatedCellHeights.webContent = webContentHeight
        }
        item.calculatedCellHeights.oneColumn = height
        item.calculatedCellHeights.multiColumn = height
    }

}
