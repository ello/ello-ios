////
///  PromotionalHeaderCellSizeCalculator.swift
//


class PromotionalHeaderCellSizeCalculator: CellSizeCalculator {
    struct Size {
        static let minIpadHeight: CGFloat = 300
        static let minPhoneHeight: CGFloat = 150
    }

    private let minHeight: CGFloat

    var webWidth: CGFloat {
        var webWidth = width
        webWidth -= 2 * PromotionalHeaderCell.Size.defaultMargin
        return webWidth
    }

    var webView: UIWebView = ElloWebView() { didSet { didSetWebView() } }

    override init(item: StreamCellItem, width: CGFloat, columnCount: Int) {
        if Globals.isIpad {
            minHeight = Size.minIpadHeight
        }
        else {
            minHeight = Size.minPhoneHeight
        }

        super.init(item: item, width: width, columnCount: columnCount)
        didSetWebView()
    }

    private func didSetWebView() {
        webView.frame = CGRect(x: 0, y: 0, width: webWidth, height: 0)
        webView.delegate = self
    }

    static func calculatePageHeaderHeight(
        _ pageHeader: PageHeader,
        htmlHeight: CGFloat?,
        cellWidth: CGFloat
    ) -> CGFloat {
        let config = PromotionalHeaderCell.Config(pageHeader: pageHeader)
        var calcHeight: CGFloat = 0
        let textWidth = cellWidth - 2 * PromotionalHeaderCell.Size.defaultMargin
        let boundingSize = CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude)

        calcHeight += PromotionalHeaderCell.Size.topMargin
        let attributedTitle = config.attributedTitle
        calcHeight += attributedTitle.heightForWidth(textWidth)

        if let htmlHeight = htmlHeight, config.hasHtml {
            calcHeight += htmlHeight
        }
        else if let attributedBody = config.attributedBody, !config.hasHtml {
            calcHeight += PromotionalHeaderCell.Size.bodySpacing
            calcHeight += attributedBody.heightForWidth(textWidth)
        }

        let ctaSize: CGSize
        if let attributedCallToAction = config.attributedCallToAction {
            ctaSize =
                attributedCallToAction.boundingRect(with: boundingSize, options: [], context: nil)
                .size.integral
        }
        else {
            ctaSize = .zero
        }

        let postedBySize: CGSize
        if let attributedPostedBy = config.attributedPostedBy {
            postedBySize =
                attributedPostedBy.boundingRect(with: boundingSize, options: [], context: nil).size
                .integral
        }
        else {
            postedBySize = .zero
        }

        calcHeight += PromotionalHeaderCell.Size.bodySpacing
        if ctaSize.width + postedBySize.width > textWidth {
            calcHeight += ctaSize.height + PromotionalHeaderCell.Size.stackedMargin
                + postedBySize.height
        }
        else {
            calcHeight += max(ctaSize.height, postedBySize.height)
        }

        calcHeight += PromotionalHeaderCell.Size.defaultMargin
        return calcHeight
    }

    override func process() {
        guard let pageHeader = cellItem.jsonable as? PageHeader else {
            finish()
            return
        }

        if pageHeader.kind == .category {
            let calcHeight = PromotionalHeaderCellSizeCalculator.calculatePageHeaderHeight(
                pageHeader,
                htmlHeight: nil,
                cellWidth: width
            )
            let height = max(minHeight, calcHeight)
            assignCellHeight(all: height)
        }
        else if pageHeader.kind.hasHtml {
            let text = pageHeader.subheader
            let html = StreamTextCellHTML.editorialHTML(text)
            webView.loadHTMLString(html, baseURL: URL(string: "/"))
        }
        else {
            calculateHeight(pageHeader: pageHeader, htmlHeight: nil)
        }
    }

    private func calculateHeight(pageHeader: PageHeader, htmlHeight: CGFloat?) {
        let calcHeight = PromotionalHeaderCellSizeCalculator.calculatePageHeaderHeight(
            pageHeader,
            htmlHeight: htmlHeight,
            cellWidth: width
        )
        let height = max(minHeight, calcHeight)
        assignCellHeight(all: height)
    }
}

extension PromotionalHeaderCellSizeCalculator: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        guard let pageHeader = cellItem.jsonable as? PageHeader else {
            finish()
            return
        }

        let htmlHeight = webView.windowContentSize()?.height
        calculateHeight(pageHeader: pageHeader, htmlHeight: htmlHeight)
    }
}
