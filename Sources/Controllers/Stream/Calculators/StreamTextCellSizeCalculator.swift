////
///  StreamTextCellSizeCalculator.swift
//

class StreamTextCellSizeCalculator: NSObject, UIWebViewDelegate {
    let webView: UIWebView
    fileprivate typealias CellJob = (cellItems: [StreamCellItem], width: CGFloat, columnCount: Int, completion: Block)
    fileprivate var cellJobs: [CellJob] = []
    fileprivate var cellItems: [StreamCellItem] = []
    fileprivate var maxWidth: CGFloat
    fileprivate var completion: Block = {}

    init(webView: UIWebView = ElloWebView()) {
        self.webView = webView
        self.maxWidth = 0
        super.init()
        self.webView.delegate = self
    }

// MARK: Public

    func processCells(_ cellItems: [StreamCellItem], withWidth width: CGFloat, columnCount: Int, completion: @escaping Block) {
        guard cellItems.count > 0 else {
            completion()
            return
        }

        let job: CellJob = (cellItems: cellItems, width: width, columnCount: columnCount, completion: completion)
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
        if job.columnCount == 1 {
            self.maxWidth = job.width
        }
        else {
            self.maxWidth = floor(job.width / CGFloat(job.columnCount) - StreamKind.following.columnSpacing * CGFloat(job.columnCount - 1))
        }
        loadNext()
    }

    fileprivate func loadNext() {
        guard !self.cellItems.isEmpty else {
            completion()
            return
        }

        let item = cellItems[0]
        if item.jsonable is ElloComment {
            // need to add back in the postMargin (15) since the maxWidth should already
            // account for 15 on the left that is part of the commentMargin (60)
            self.webView.frame = self.webView.frame.with(width: maxWidth - StreamTextCell.Size.commentMargin + StreamTextCell.Size.postMargin)
        }
        else {
            self.webView.frame = self.webView.frame.with(width: maxWidth)
        }

        if let textElement = item.type.data as? TextRegion {
            let content = textElement.content
            let strippedContent = content.stripHtmlImgSrc()
            let html = StreamTextCellHTML.postHTML(strippedContent)
            // needs to use the same width as the post text region
            self.webView.loadHTMLString(html, baseURL: URL(string: "/"))
        }
        else {
            self.cellItems.remove(at: 0)
            loadNext()
        }
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        let textHeight = self.webView.windowContentSize()?.height
        assignCellHeight(textHeight ?? 0)
    }

    fileprivate func assignCellHeight(_ height: CGFloat) {
        if let cellItem = self.cellItems.safeValue(0) {
            self.cellItems.remove(at: 0)
            cellItem.calculatedCellHeights.webContent = height
            cellItem.calculatedCellHeights.oneColumn = height
            cellItem.calculatedCellHeights.multiColumn = height
        }
        loadNext()
    }

}
