////
///  ProfileBioSizeCalculator.swift
//

import PromiseKit


class ProfileBioSizeCalculator: NSObject {
    let webView = UIWebView()
    var fulfill: ((CGFloat) -> Void)?

    deinit {
        webView.delegate = nil
    }

    func calculate(_ item: StreamCellItem, maxWidth: CGFloat) -> Promise<CGFloat> {
        let (promise, fulfill, _) = Promise<CGFloat>.pending()
        guard
            let user = item.jsonable as? User,
            let formattedShortBio = user.formattedShortBio, !formattedShortBio.isEmpty
        else {
            fulfill(0)
            return promise
        }

        guard !AppSetup.sharedState.isTesting else {
            fulfill(ProfileBioSizeCalculator.calculateHeight(webViewHeight: 30))
            return promise
        }

        webView.frame.size.width = maxWidth
        webView.delegate = self
        webView.loadHTMLString(StreamTextCellHTML.postHTML(formattedShortBio), baseURL: URL(string: "/"))
        self.fulfill = fulfill
        return promise
    }

    static func calculateHeight(webViewHeight: CGFloat) -> CGFloat {
        guard webViewHeight > 0 else {
            return 0
        }
        return webViewHeight + ProfileBioView.Size.margins.top + ProfileBioView.Size.margins.bottom
    }

}

extension ProfileBioSizeCalculator: UIWebViewDelegate {

    func webViewDidFinishLoad(_ webView: UIWebView) {
        let webViewHeight = webView.windowContentSize()?.height ?? 0
        let totalHeight = ProfileBioSizeCalculator.calculateHeight(webViewHeight: webViewHeight)
        fulfill?(totalHeight)
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        fulfill?(0)
    }

}
