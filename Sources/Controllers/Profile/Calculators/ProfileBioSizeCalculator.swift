////
///  ProfileBioSizeCalculator.swift
//

import FutureKit


class ProfileBioSizeCalculator: NSObject {
    let webView = UIWebView()
    let promise = Promise<CGFloat>()

    deinit {
        webView.delegate = nil
    }

    func calculate(_ item: StreamCellItem, maxWidth: CGFloat) -> Future<CGFloat> {
        guard
            let user = item.jsonable as? User,
            let formattedShortBio = user.formattedShortBio, !formattedShortBio.isEmpty
        else {
            promise.completeWithSuccess(0)
            return promise.future
        }

        webView.frame.size.width = maxWidth
        webView.delegate = self
        webView.loadHTMLString(StreamTextCellHTML.postHTML(formattedShortBio), baseURL: URL(string: "/"))
        return promise.future
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
        promise.completeWithSuccess(totalHeight)
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        promise.completeWithSuccess(0)
    }

}

private extension ProfileBioSizeCalculator {}
