////
///  StreamTextCell.swift
//

import WebKit
import Foundation

class StreamTextCell: StreamRegionableCell, UIWebViewDelegate, UIGestureRecognizerDelegate {
    static let reuseIdentifier = "StreamTextCell"

    typealias WebContentReady = (_ webView: UIWebView) -> Void

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    weak var webLinkDelegate: WebLinkDelegate?
    weak var userDelegate: UserDelegate?
    var webContentReady: WebContentReady?

    override func awakeFromNib() {
        super.awakeFromNib()
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.scrollsToTop = false

        let doubleTapGesture = UITapGestureRecognizer()
        doubleTapGesture.delegate = self
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.addTarget(self, action: #selector(doubleTapped(_:)))
        webView.addGestureRecognizer(doubleTapGesture)

        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.addTarget(self, action: #selector(longPressed(_:)))
        webView.addGestureRecognizer(longPressGesture)
    }

    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }

    @IBAction func doubleTapped(_ gesture: UIGestureRecognizer) {
        let location = gesture.location(in: nil)

        let responder = target(forAction: #selector(StreamEditingResponder.cellDoubleTapped(cell:location:)), withSender: self) as? StreamEditingResponder

        responder?.cellDoubleTapped(cell: self, location: location)
    }

    @IBAction func longPressed(_ gesture: UIGestureRecognizer) {
        guard gesture.state == .began else { return }

        let responder = target(forAction: #selector(StreamEditingResponder.cellLongPressed(cell:)), withSender: self) as? StreamEditingResponder
        responder?.cellLongPressed(cell: self)
    }

    func onWebContentReady(_ handler: WebContentReady?) {
        webContentReady = handler
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        hideBorder()
        webContentReady = nil
        webView.stopLoading()
        webView.loadHTMLString("", baseURL: nil)
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let scheme = request.url?.scheme, scheme == "default"
        {
            userDelegate?.userTappedText(cell: self)
            return false
        }
        else {
            return ElloWebViewHelper.handle(request: request, webLinkDelegate: webLinkDelegate)
        }
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        webContentReady?(webView)
    }
}
