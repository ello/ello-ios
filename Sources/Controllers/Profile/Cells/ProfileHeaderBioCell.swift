////
///  ProfileHeaderBioCell.swift
//

import WebKit


class ProfileHeaderBioCell: ProfileHeaderCell {
    static let reuseIdentifier = "ProfileHeaderBioCell"

    struct Size {
        static let margins = UIEdgeInsets(top: 15, left: 15, bottom: 10, right: 15)
    }

    var bio: String = "" {
        didSet {
            bioView.loadHTMLString(StreamTextCellHTML.postHTML(bio), baseURL: URL(string: "/"))
        }
    }
    private let bioView = ElloWebView()

    override func style() {
        backgroundColor = .white
        bioView.scrollView.isScrollEnabled = false
        bioView.scrollView.scrollsToTop = false
        bioView.delegate = self
    }

    override func arrange() {
        contentView.addSubview(bioView)

        bioView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(contentView).inset(Size.margins)
            make.bottom.equalTo(contentView)
        }
    }
}

extension ProfileHeaderBioCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        self.bio = ""
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

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        return ElloWebViewHelper.handle(request: request, origin: self)
    }
}
