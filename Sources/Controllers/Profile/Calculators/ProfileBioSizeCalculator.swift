////
///  ProfileBioSizeCalculator.swift
//

import PromiseKit


class ProfileBioSizeCalculator: NSObject {
    let webView = ElloWebView()
    var resolve: ((CGFloat) -> Void)?

    deinit {
        webView.delegate = nil
    }

    func calculate(_ item: StreamCellItem, maxWidth: CGFloat) -> Promise<CGFloat> {
        let (promise, resolve, _) = Promise<CGFloat>.pending()
        guard
            let user = item.jsonable as? User,
            let formattedShortBio = user.formattedShortBio, !formattedShortBio.isEmpty
        else {
            resolve(0)
            return promise
        }

        guard !AppSetup.shared.isTesting else {
            resolve(ProfileBioSizeCalculator.calculateHeight(webViewHeight: 30))
            return promise
        }

        webView.frame.size.width = maxWidth
        webView.delegate = self
        webView.loadHTMLString(StreamTextCellHTML.postHTML(formattedShortBio), baseURL: URL(string: "/"))
        self.resolve = resolve
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
        resolve?(totalHeight)
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        resolve?(0)
    }

}
