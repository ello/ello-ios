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

    fileprivate let titleLabel = StyledLabel(style: .artistInviteGuide)
    fileprivate let guideWebView = ElloWebView()

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
