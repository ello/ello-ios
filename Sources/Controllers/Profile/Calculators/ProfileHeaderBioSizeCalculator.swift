////
///  ProfileHeaderBioSizeCalculator.swift
//

import PromiseKit


class ProfileHeaderBioSizeCalculator: CellSizeCalculator {
    var webView: UIWebView = ElloWebView() { didSet { didSetWebView() } }

    static func calculateHeight(webViewHeight: CGFloat) -> CGFloat {
        guard webViewHeight > 0 else { return 0 }
        return webViewHeight + ProfileHeaderBioCell.Size.margins.tops
    }

    override init(item: StreamCellItem, width: CGFloat, columnCount: Int) {
        super.init(item: item, width: width, columnCount: columnCount)
        didSetWebView()
    }

    private func didSetWebView() {
        webView.frame.size.width = width
        webView.delegate = self
    }

    override func process() {
        guard
            let user = cellItem.jsonable as? User,
            let formattedShortBio = user.formattedShortBio,
            !formattedShortBio.isEmpty
        else {
            assignCellHeight(all: 0)
            return
        }

        guard !Globals.isTesting else {
            assignCellHeight(all: ProfileHeaderBioSizeCalculator.calculateHeight(webViewHeight: 30))
            return
        }

        webView.loadHTMLString(StreamTextCellHTML.postHTML(formattedShortBio), baseURL: URL(string: "/"))
    }
}

extension ProfileHeaderBioSizeCalculator: UIWebViewDelegate {

    func webViewDidFinishLoad(_ webView: UIWebView) {
        let webViewHeight = webView.windowContentSize()?.height ?? 0
        let totalHeight = ProfileHeaderBioSizeCalculator.calculateHeight(webViewHeight: webViewHeight)
        assignCellHeight(all: totalHeight)
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        assignCellHeight(all: 0)
    }

}
