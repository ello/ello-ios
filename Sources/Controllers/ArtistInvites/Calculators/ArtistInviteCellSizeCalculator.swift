////
///  ArtistInviteCellSizeCalculator.swift
//

class ArtistInviteCellSizeCalculator: CellSizeCalculator {
    var webWidth: CGFloat {
        var webWidth = width
        webWidth -= ArtistInviteBubbleCell.Size.bubbleMargins.sides
        webWidth -= ArtistInviteBubbleCell.Size.descriptionMargins.sides
        return webWidth
    }

    var webView: UIWebView = ElloWebView() { didSet { didSetWebView() } }

    override init(item: StreamCellItem, width: CGFloat, columnCount: Int) {
        super.init(item: item, width: width, columnCount: columnCount)
        didSetWebView()
    }

    private func didSetWebView() {
        webView.frame = CGRect(x: 0, y: 0, width: webWidth, height: 0)
        webView.delegate = self
    }

    override func process() {
        guard let artistInvite = cellItem.jsonable as? ArtistInvite else {
            finish()
            return
        }

        switch cellItem.type {
        case .artistInviteBubble:
            loadBubbleHTML(cellItem, artistInvite)
        case .artistInviteHeader:
            calculateHeight(webHeight: 0)
        case .artistInviteControls:
            loadControlsHTML(cellItem, artistInvite)
        case .artistInviteGuide:
            loadGuideHTML(cellItem, artistInvite)
        default:
            finish()
        }
    }

    private func loadBubbleHTML(_ item: StreamCellItem, _ artistInvite: ArtistInvite) {
        let text = artistInvite.shortDescription
        let html = StreamTextCellHTML.artistInviteHTML(text)
        webView.loadHTMLString(html, baseURL: URL(string: "/"))
    }

    private func loadControlsHTML(_ item: StreamCellItem, _ artistInvite: ArtistInvite) {
        let text = artistInvite.longDescription
        let html = StreamTextCellHTML.postHTML(text)
        webView.loadHTMLString(html, baseURL: URL(string: "/"))
    }

    private func loadGuideHTML(_ item: StreamCellItem, _ artistInvite: ArtistInvite) {
        guard let guide = item.type.data as? ArtistInvite.Guide else {
            finish()
            return
        }

        let text = guide.html
        let html = StreamTextCellHTML.artistInviteGuideHTML(text)
        webView.loadHTMLString(html, baseURL: URL(string: "/"))
    }

    private func calculateHeight(webHeight: CGFloat) {
        let calculatedHeight: CGFloat
        switch cellItem.type {
        case .artistInviteBubble:
            calculatedHeight = calculateBubbleHeight(cellItem, webHeight)
        case .artistInviteHeader:
            calculatedHeight = calculateHeaderHeight(cellItem)
        case .artistInviteControls:
            calculatedHeight = calculateControlsHeight(cellItem, webHeight)
        case .artistInviteGuide:
            calculatedHeight = calculateGuideHeight(cellItem, webHeight)
        default:
            finish()
            return
        }

        assignCellHeight(all: calculatedHeight)
    }

    private func calculateBubbleHeight(_ item: StreamCellItem, _ webHeight: CGFloat) -> CGFloat {
        var totalHeight = webHeight
        totalHeight += ArtistInviteBubbleCell.Size.bubbleMargins.top
        totalHeight += ArtistInviteBubbleCell.Size.headerImageHeight
        if let artistInvite = item.jsonable as? ArtistInvite {
            totalHeight += ArtistInviteBubbleCell.calculateDynamicHeights(title: artistInvite.title, inviteType: artistInvite.inviteType, cellWidth: width)
        }
        totalHeight += ArtistInviteBubbleCell.Size.infoTotalHeight
        totalHeight += (webHeight > 0 ? ArtistInviteBubbleCell.Size.descriptionMargins.bottom : 0)
        totalHeight += ArtistInviteBubbleCell.Size.bubbleMargins.bottom
        return totalHeight
    }

    private func calculateHeaderHeight(_ item: StreamCellItem) -> CGFloat {
        var totalHeight: CGFloat = 0
        totalHeight += ArtistInviteHeaderCell.Size.headerImageHeight
        totalHeight += ArtistInviteHeaderCell.Size.remainingTextHeight
        if let artistInvite = item.jsonable as? ArtistInvite {
            totalHeight += ArtistInviteHeaderCell.calculateDynamicHeights(title: artistInvite.title, inviteType: artistInvite.inviteType, cellWidth: width)
        }
        return totalHeight
    }

    private func calculateControlsHeight(_ item: StreamCellItem, _ webHeight: CGFloat) -> CGFloat {
        let isOpen: Bool
        if let artistInvite = item.jsonable as? ArtistInvite {
            isOpen = artistInvite.status == .open
        }
        else {
            isOpen = false
        }

        var totalHeight = webHeight
        if isOpen {
            totalHeight += ArtistInviteControlsCell.Size.controlsHeight
        }
        else {
            totalHeight += ArtistInviteControlsCell.Size.closedControlsHeight
        }
        return totalHeight
    }

    private func calculateGuideHeight(_ item: StreamCellItem, _ webHeight: CGFloat) -> CGFloat {
        return ArtistInviteGuideCell.Size.otherHeights + webHeight
    }
}

extension ArtistInviteCellSizeCalculator: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let textHeight = webView.windowContentSize()?.height ?? 0
        calculateHeight(webHeight: textHeight)
    }
}
