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
                setupWebView(UIWebView())
                let wrappedHtml = StreamTextCellHTML.postHTML(html)
                webView.loadHTMLString(wrappedHtml, baseURL: URL(string: "/"))
            }
        }
    }

    fileprivate var webView = UIWebView()
    fileprivate var webViewContainer = UIView()
    fileprivate var leadingConstraint: Constraint!
    fileprivate let doubleTapGesture = UITapGestureRecognizer()
    fileprivate let longPressGesture = UILongPressGestureRecognizer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        arrange()
        setupWebView(webView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupWebView(_ webView: UIWebView) {
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

    func arrange() {
        contentView.addSubview(webViewContainer)

        webViewContainer.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView)
            make.trailing.equalTo(contentView).offset(-Size.trailingMargin)
            leadingConstraint = make.leading.equalTo(contentView).offset(Size.postMargin).constraint
        }
    }

    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }

    @IBAction func doubleTapped(_ gesture: UIGestureRecognizer) {
        let location = gesture.location(in: nil)

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

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let scheme = request.url?.scheme, scheme == "default"
        {
            let responder: UserResponder? = findResponder()
            responder?.userTappedText(cell: self)
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
