////
///  StreamNotificationCellSizeCalculator.swift
//


class StreamNotificationCellSizeCalculator: NSObject, UIWebViewDelegate {
    fileprivate static let textViewForSizing = ElloTextView(frame: CGRect.zero, textContainer: nil)
    let webView: UIWebView
    var originalWidth: CGFloat = 0

    fileprivate typealias CellJob = (cellItems: [StreamCellItem], width: CGFloat, completion: Block)
    fileprivate var cellJobs: [CellJob] = []
    fileprivate var cellItems: [StreamCellItem] = []
    fileprivate var completion: Block = {}

    init(webView: UIWebView = ElloWebView()) {
        self.webView = webView
        super.init()
        self.webView.delegate = self
    }

// MARK: Public

    func processCells(_ cellItems: [StreamCellItem], withWidth width: CGFloat, completion: @escaping Block) {
        guard cellItems.count > 0 else {
            completion()
            return
        }

        let job: CellJob = (cellItems: cellItems, width: width, completion: completion)
        cellJobs.append(job)
        if cellJobs.count == 1 {
            processJob(job)
        }
    }

// MARK: Private

    fileprivate func processJob(_ job: CellJob) {
        self.completion = {
            if self.cellJobs.count > 0 {
                self.cellJobs.remove(at: 0)
            }
            job.completion()
            if let nextJob = self.cellJobs.safeValue(0) {
                self.processJob(nextJob)
            }
        }
        self.cellItems = job.cellItems
        self.originalWidth = job.width
        self.webView.frame = self.webView.frame.with(width: job.width)
        loadNext()
    }

    fileprivate func loadNext() {
        if let item = self.cellItems.safeValue(0) {
            if let notification = item.jsonable as? Notification,
                let textRegion = notification.textRegion
            {
                let content = textRegion.content
                let strippedContent = content.stripHtmlImgSrc()
                let html = StreamTextCellHTML.postHTML(strippedContent)
                var f = self.webView.frame
                f.size.width = NotificationCell.Size.messageHtmlWidth(forCellWidth: originalWidth, hasImage: notification.hasImage)
                self.webView.frame = f
                self.webView.loadHTMLString(html, baseURL: URL(string: "/"))
            }
            else {
                assignCellHeight(0)
            }
        }
        else {
            completion()
        }
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        if let webContentHeight = self.webView.windowContentSize()?.height {
            assignCellHeight(webContentHeight)
        }
        else {
            assignCellHeight(0)
        }
    }

    fileprivate func assignCellHeight(_ webContentHeight: CGFloat) {
        if let cellItem = self.cellItems.safeValue(0) {
            self.cellItems.remove(at: 0)
            StreamNotificationCellSizeCalculator.assignTotalHeight(webContentHeight, cellItem: cellItem, cellWidth: originalWidth)
        }
        loadNext()
    }

    class func assignTotalHeight(_ webContentHeight: CGFloat?, cellItem: StreamCellItem, cellWidth: CGFloat) {
        let notification = cellItem.jsonable as! Notification

        textViewForSizing.attributedText = NotificationAttributedTitle.from(notification: notification)
        let titleWidth = NotificationCell.Size.messageHtmlWidth(forCellWidth: cellWidth, hasImage: notification.hasImage)
        let titleSize = textViewForSizing.sizeThatFits(CGSize(width: titleWidth, height: .greatestFiniteMagnitude))
        var totalTextHeight = ceil(titleSize.height)
        totalTextHeight += NotificationCell.Size.CreatedAtFixedHeight

        if let webContentHeight = webContentHeight, webContentHeight > 0 {
            totalTextHeight += webContentHeight + NotificationCell.Size.WebHeightCorrection + NotificationCell.Size.InnerMargin
        }

        if notification.canReplyToComment || notification.canBackFollow {
            totalTextHeight += NotificationCell.Size.ButtonHeight + NotificationCell.Size.InnerMargin
        }

        let totalImageHeight = NotificationCell.Size.imageHeight(imageRegion: notification.imageRegion)
        var height = max(totalTextHeight, totalImageHeight)

        height += 2 * NotificationCell.Size.SideMargins
        if let webContentHeight = webContentHeight {
            cellItem.calculatedCellHeights.webContent = webContentHeight
        }
        cellItem.calculatedCellHeights.oneColumn = height
        cellItem.calculatedCellHeights.multiColumn = height
    }

}
