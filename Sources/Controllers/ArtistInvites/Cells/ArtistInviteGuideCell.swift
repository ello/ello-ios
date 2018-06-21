////
///  ArtistInviteGuideCell.swift
//

import SnapKit


class ArtistInviteGuideCell: CollectionViewCell {
    static let reuseIdentifier = "ArtistInviteGuideCell"

    struct Size {
        static let otherHeights: CGFloat = 56

        static let margins = UIEdgeInsets(sides: 15)
        static let guideSpacing: CGFloat = 20
    }

    typealias Config = ArtistInvite.Guide

    var config: Config? {
        didSet {
            updateConfig()
        }
    }

    private let titleLabel = StyledLabel(style: .artistInviteGuide)
    private let guideWebView = ElloWebView()

    override func bindActions() {
        guideWebView.delegate = self
    }

    override func arrange() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(guideWebView)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(contentView).inset(Size.margins)
        }

        guideWebView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Size.guideSpacing)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalTo(contentView)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        config = nil
    }

    func updateConfig() {
        titleLabel.text = config?.title
        let htmlString: String
        if let html = config?.html {
            htmlString = StreamTextCellHTML.artistInviteGuideHTML(html)
        }
        else {
            htmlString = ""
        }
        guideWebView.loadHTMLString(htmlString, baseURL: URL(string: "/"))
    }
}

extension StyledLabel.Style {
    static let artistInviteGuide = StyledLabel.Style(
        textColor: .greyA,
        fontFamily: .artistInviteTitle
        )
}

extension ArtistInviteGuideCell: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let scheme = request.url?.scheme, scheme == "default" {
            let responder: StreamCellResponder? = findResponder()
            responder?.streamCellTapped(cell: self)
            return false
        }
        else {
            return ElloWebViewHelper.handle(request: request, origin: self)
        }
    }
}
