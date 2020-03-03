////
///  StreamTextCellSizeCalculator.swift
//

class StreamTextCellSizeCalculator: CellSizeCalculator, UIWebViewDelegate {
    let streamKind: StreamKind

    var columnWidth: CGFloat {
        var columnWidth: CGFloat
        if columnCount == 1 {
            columnWidth = width
        }
        else {
            let columnCountFloat = CGFloat(columnCount)
            columnWidth = floor(
                width / columnCountFloat - StreamKind.following.horizontalColumnSpacing * (
                    columnCountFloat - 1
                )
            )
        }

        // subtract right margin
        columnWidth -= StreamTextCell.Size.postMargin

        // subtract left margin – changes depending on comment vs post
        if cellItem.jsonable is ElloComment {
            columnWidth -= StreamTextCell.Size.commentMargin
        }
        else {
            columnWidth -= StreamTextCell.Size.postMargin
        }

        // subtract repost content indent
        if let textRegion = cellItem.type.data as? TextRegion, textRegion.isRepost {
            columnWidth -= StreamTextCell.Size.repostMargin
        }
        return columnWidth
    }

    var webView: UIWebView = ElloWebView() { didSet { didSetWebView() } }

    init(streamKind: StreamKind, item: StreamCellItem, width: CGFloat, columnCount: Int) {
        self.streamKind = streamKind
        super.init(item: item, width: width, columnCount: columnCount)
        didSetWebView()
    }

    private func didSetWebView() {
        webView.frame = CGRect(x: 0, y: 0, width: columnWidth, height: 0)
        webView.delegate = self
    }

    override func process() {
        guard let textElement = cellItem.type.data as? TextRegion else {
            finish()
            return
        }

        let content = textElement.content
        let strippedContent = content.stripHtmlImgSrc()
        let html = StreamTextCellHTML.postHTML(strippedContent)
        // needs to use the same width as the post text region
        webView.loadHTMLString(html, baseURL: URL(string: "/"))
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        let textHeight = self.webView.windowContentSize()?.height ?? 0
        assignCellHeight(one: textHeight, multi: textHeight, web: textHeight)
    }
}
