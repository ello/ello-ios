////
///  ProfileBioView.swift
//

import WebKit


class ProfileBioView: ProfileBaseView {
    struct Size {
        static let margins = UIEdgeInsets(top: 15, left: 15, bottom: 10, right: 15)
    }

    var bio: String = "" {
        didSet {
            bioView.loadHTMLString(StreamTextCellHTML.postHTML(bio), baseURL: URL(string: "/"))
        }
    }
    fileprivate let bioView = UIWebView()
    fileprivate let grayLine = UIView()
    var grayLineVisible: Bool {
        get { return !grayLine.isHidden }
        set { grayLine.isHidden = !newValue }
    }

    weak var webLinkDelegate: WebLinkDelegate?

    var onHeightMismatch: OnHeightMismatch?
}

extension ProfileBioView {

    override func style() {
        backgroundColor = .white
        bioView.scrollView.isScrollEnabled = false
        bioView.scrollView.scrollsToTop = false
        bioView.delegate = self
        grayLine.backgroundColor = .greyE5()
    }

    override func bindActions() {
    }

    override func setText() {
    }

    override func arrange() {
        addSubview(bioView)
        addSubview(grayLine)

        bioView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self).inset(Size.margins)
            make.bottom.equalTo(self)
        }

        grayLine.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.equalTo(self)
            make.leading.trailing.equalTo(self).inset(ProfileBaseView.Size.grayInset)
        }
    }

    func prepareForReuse() {
        self.bio = ""
        grayLine.isHidden = false
        webLinkDelegate = nil
    }
}

extension ProfileBioView: UIWebViewDelegate {

    func webViewDidFinishLoad(_ webView: UIWebView) {
        let webViewHeight = webView.windowContentSize()?.height ?? 0
        let totalHeight: CGFloat
        if bio == "" {
            totalHeight = 0
        }
        else {
            totalHeight = ProfileBioSizeCalculator.calculateHeight(webViewHeight: webViewHeight)
        }
        if totalHeight != frame.size.height {
            onHeightMismatch?(totalHeight)
        }
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return ElloWebViewHelper.handle(request: request, webLinkDelegate: webLinkDelegate)
    }
}

extension ProfileBioView: ProfileViewProtocol {}
