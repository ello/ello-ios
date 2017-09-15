////
///  ArtistInviteCellSizeCalculator.swift
//

class ArtistInviteCellSizeCalculator: NSObject {
    let webView: UIWebView
    fileprivate typealias CellJob = (cellItems: [StreamCellItem], width: CGFloat, hasCurrentUser: Bool, completion: Block)
    fileprivate var cellJobs: [CellJob] = []
    fileprivate var job: CellJob?
    fileprivate var completion: Block = {}

    init(webView: UIWebView = ElloWebView()) {
        self.webView = webView
        super.init()
        self.webView.delegate = self
    }

// MARK: Public

    func processCells(_ cellItems: [StreamCellItem], withWidth width: CGFloat, hasCurrentUser: Bool, completion: @escaping Block) {
        guard cellItems.count > 0 else {
            completion()
            return
        }

        let job: CellJob = (cellItems: cellItems, width: width, hasCurrentUser: hasCurrentUser, completion: completion)
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

        self.job = job
        var webWidth = job.width
        webWidth -= ArtistInviteBubbleCell.Size.bubbleMargins.left + ArtistInviteBubbleCell.Size.bubbleMargins.right
        webWidth -= ArtistInviteBubbleCell.Size.descriptionMargins.left + ArtistInviteBubbleCell.Size.descriptionMargins.right
        webView.frame = webView.frame.with(width: webWidth)

        loadNext()
    }

    fileprivate func loadNext() {
        guard let job = job else { return }
        guard !job.cellItems.isEmpty else {
            completion()
            return
        }

        let cellItem = job.cellItems[0]
        guard
            let artistInvite = cellItem.jsonable as? ArtistInvite
        else {
            assignHeight(nil)
            return
        }

        switch cellItem.type {
        case .artistInviteBubble:
            calculateBubbleHeight(cellItem, artistInvite)
        case .artistInviteControls:
            calculateControlsHeight(cellItem, artistInvite)
        case .artistInviteGuide:
            calculateGuideHeight(cellItem, artistInvite)
        default:
            assignHeight(nil)
        }
    }

    fileprivate func calculateBubbleHeight(_ cellItem: StreamCellItem, _ artistInvite: ArtistInvite) {
        let text = artistInvite.shortDescription
        let html = StreamTextCellHTML.artistInviteHTML(text)
        webView.loadHTMLString(html, baseURL: URL(string: "/"))
    }

    fileprivate func calculateControlsHeight(_ cellItem: StreamCellItem, _ artistInvite: ArtistInvite) {
        let text = artistInvite.longDescription
        let html = StreamTextCellHTML.postHTML(text)
        webView.loadHTMLString(html, baseURL: URL(string: "/"))
    }

    fileprivate func calculateGuideHeight(_ cellItem: StreamCellItem, _ artistInvite: ArtistInvite) {
        guard let guide = cellItem.type.data as? ArtistInvite.Guide else {
            assignHeight(nil)
            return
        }
        let text = guide.html
        let html = StreamTextCellHTML.artistInviteGuideHTML(text)
        webView.loadHTMLString(html, baseURL: URL(string: "/"))
    }

    fileprivate func assignHeight(_ height: CGFloat?) {
        guard var job = job else { return }
        let cellItem = job.cellItems.remove(at: 0)
        self.job = job
        defer {
            loadNext()
        }
        guard let height = height else { return }

        let calculatedHeight: CGFloat?
        switch cellItem.type {
        case .artistInviteBubble:
            calculatedHeight = assignBubbleHeight(cellItem, height)
        case .artistInviteControls:
            calculatedHeight = assignControlsHeight(cellItem, height, hasCurrentUser: job.hasCurrentUser)
        case .artistInviteGuide:
            calculatedHeight = assignGuideHeight(cellItem, height)
        default:
            calculatedHeight = nil
        }

        if let height = calculatedHeight {
            cellItem.calculatedCellHeights.webContent = height
            cellItem.calculatedCellHeights.oneColumn = height
            cellItem.calculatedCellHeights.multiColumn = height
        }
    }

    fileprivate func assignBubbleHeight(_ cellItem: StreamCellItem, _ height: CGFloat) -> CGFloat {
        var totalHeight = height
        totalHeight += ArtistInviteBubbleCell.Size.bubbleMargins.top
        totalHeight += ArtistInviteBubbleCell.Size.headerImageHeight
        totalHeight += ArtistInviteBubbleCell.Size.infoTotalHeight
        totalHeight += (height > 0 ? ArtistInviteBubbleCell.Size.descriptionMargins.bottom : 0)
        totalHeight += ArtistInviteBubbleCell.Size.bubbleMargins.bottom
        return totalHeight
    }

    fileprivate func assignControlsHeight(_ cellItem: StreamCellItem, _ height: CGFloat, hasCurrentUser: Bool) -> CGFloat {
        let isOpen: Bool
        if let artistInvite = cellItem.jsonable as? ArtistInvite {
            isOpen = artistInvite.status == .open
        }
        else {
            isOpen = false
        }

        var totalHeight = height
        if hasCurrentUser && isOpen {
            totalHeight += ArtistInviteControlsCell.Size.controlsHeight
        }
        else {
            totalHeight += ArtistInviteControlsCell.Size.loggedOutControlsHeight
        }
        return totalHeight
    }

    fileprivate func assignGuideHeight(_ cellItem: StreamCellItem, _ height: CGFloat) -> CGFloat {
        return ArtistInviteGuideCell.Size.otherHeights + height
    }
}

extension ArtistInviteCellSizeCalculator: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let textHeight = webView.windowContentSize()?.height
        assignHeight(textHeight ?? 0)
    }
}
