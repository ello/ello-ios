////
///  StreamTextCell.swift
//

import WebKit
import SnapKit


class StreamTextCell: StreamRegionableCell, UIWebViewDelegate, UIGestureRecognizerDelegate {
    static let reuseIdentifier = "StreamTextCell"

    struct Size {
        static let postMargin: CGFloat = 15
        static let trailingMargin: CGFloat = 15
        static let commentMargin: CGFloat = 60
        static let repostMargin: CGFloat = 30
    }

    enum Margin {
        case post
        case comment
        case repost

        var value: CGFloat {
            switch self {
            case .post:
                return Size.postMargin
            case .comment:
                return Size.commentMargin
            case .repost:
                return Size.repostMargin
            }
        }
    }

    typealias WebContentReady = (_ webView: UIWebView) -> Void
    var webContentReady: WebContentReady?
    var margin: Margin = .post {
        didSet {
            leadingConstraint.update(offset: margin.value)
        }
    }
    var html: String = "" {
        didSet {
            if html != oldValue {
                installWebView(ElloWebView())
                let wrappedHtml = StreamTextCellHTML.postHTML(html)
                webView.loadHTMLString(wrappedHtml, baseURL: URL(string: "/"))
            }
        }
    }

    private var webView = ElloWebView()
    private var webViewContainer = Container()
    private var leadingConstraint: Constraint!
    private let doubleTapGesture = UITapGestureRecognizer()
    private let longPressGesture = UILongPressGestureRecognizer()

    func installWebView(_ webView: ElloWebView) {
        self.webView.delegate = nil
        self.webView.removeFromSuperview()

        webView.delegate = self
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.scrollsToTop = false

        doubleTapGesture.delegate = self
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.addTarget(self, action: #selector(doubleTapped(_:)))
        webView.addGestureRecognizer(doubleTapGesture)

        longPressGesture.addTarget(self, action: #selector(longPressed(_:)))
        webView.addGestureRecognizer(longPressGesture)

        webViewContainer.addSubview(webView)

        webView.snp.makeConstraints { make in
            make.edges.equalTo(webViewContainer)
        }
        self.webView = webView
    }

    override func arrange() {
        installWebView(webView)
        contentView.addSubview(webViewContainer)

        webViewContainer.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView)
            make.trailing.equalTo(contentView).offset(-Size.trailingMargin)
            leadingConstraint = make.leading.equalTo(contentView).offset(Size.postMargin).constraint
        }
    }

    func gestureRecognizer(
        _: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer
    ) -> Bool {
        return true
    }

    @IBAction func doubleTapped(_ gesture: UIGestureRecognizer) {
        guard let appViewController:AppViewController = findResponder() else { return }
        let location = gesture.location(in: appViewController.view)

        let responder: StreamEditingResponder? = findResponder()
        responder?.cellDoubleTapped(cell: self, location: location)
    }

    @IBAction func longPressed(_ gesture: UIGestureRecognizer) {
        guard gesture.state == .began else { return }

        let responder: StreamEditingResponder? = findResponder()
        responder?.cellLongPressed(cell: self)
    }

    func onWebContentReady(_ handler: WebContentReady?) {
        webContentReady = handler
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        hideBorder()
        webContentReady = nil
    }

    func webView(
        _ webView: UIWebView,
        shouldStartLoadWith request: URLRequest,
        navigationType: UIWebView.NavigationType
    ) -> Bool {
        if let scheme = request.url?.scheme, scheme == "default" {
            let responder: StreamCellResponder? = findResponder()
            responder?.streamCellTapped(cell: self)
            return false
        }
        else {
            return ElloWebViewHelper.handle(request: request, origin: self)
        }
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        webContentReady?(webView)
    }
}
