////
///  ElloWebViewHelper.swift
//

struct ElloWebViewHelper {
    static let jsCommandProtocol = "ello://"

    @discardableResult
    static func handle(request: URLRequest, origin: UIResponder?, fromWebView: Bool = false) -> Bool
    {
        guard let requestUrlString = request.url?.absoluteString
        else { return true }

        if requestUrlString.hasPrefix(ElloWebViewHelper.jsCommandProtocol) {
            return false
        }
        else if requestUrlString.range(
            of: "(https?:\\/\\/|mailto:)",
            options: String.CompareOptions.regularExpression
        ) != nil {
            let (type, data) = ElloURI.match(requestUrlString)
            if type == .email {
                if let url = URL(string: requestUrlString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                return false
            }
            else {
                if fromWebView && type.loadsInWebViewFromWebView { return true }
                let responder: WebLinkResponder? = origin?.findResponder()
                responder?.webLinkTapped(
                    path: requestUrlString,
                    type: ElloURIWrapper(uri: type),
                    data: data
                )
                return false
            }
        }
        return true
    }

    static func bypassInAppBrowser(_ url: URL?) -> Bool {
        guard let urlString = url?.absoluteString else { return false }

        if urlString =~ "(https?:\\/\\/appstore.com)" { return true }
        if urlString =~ "(https?:\\/\\/itunes.apple.com)" { return true }

        return false
    }
}
