////
///  ProfileHeaderBioCell.swift
//

import WebKit


class ProfileHeaderBioCell: ProfileHeaderCell {
    static let reuseIdentifier = "ProfileHeaderBioCell"

    struct Size {
        static let margins = UIEdgeInsets(top: 15, left: 15, bottom: 10, right: 15)
        static let grayInsets: CGFloat = 15
    }

    var bio: String = "" {
        didSet {
            bioView.loadHTMLString(StreamTextCellHTML.postHTML(bio), baseURL: URL(string: "/"))
        }
    }
    private let bioView = ElloWebView()
    private let grayLine = UIView()
    var grayLineVisible: Bool {
        get { return !grayLine.isHidden }
        set { grayLine.isVisible = newValue }
    }

    override func style() {
        backgroundColor = .white
        bioView.scrollView.isScrollEnabled = false
        bioView.scrollView.scrollsToTop = false
        bioView.delegate = self
        grayLine.backgroundColor = .greyE5
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
            make.leading.trailing.equalTo(self).inset(Size.grayInsets)
        }
    }
}

extension ProfileHeaderBioCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        self.bio = ""
        grayLine.isVisible = true
    }
}

extension ProfileHeaderBioCell: UIWebViewDelegate {

    func webViewDidFinishLoad(_ webView: UIWebView) {
        guard let webViewHeight = webView.windowContentSize()?.height else { return }

        let totalHeight: CGFloat
        if bio == "" {
            totalHeight = 0
        }
        else {
            totalHeight = ProfileHeaderBioSizeCalculator.calculateHeight(webViewHeight: webViewHeight)
        }

        if totalHeight != frame.size.height {
            heightMismatchOccurred(totalHeight)
        }
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return ElloWebViewHelper.handle(request: request, origin: self)
    }
}
