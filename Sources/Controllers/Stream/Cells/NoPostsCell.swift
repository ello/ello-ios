////
///  NoPostsCell.swift
//

class NoPostsCell: CollectionViewCell {
    static let reuseIdentifier = "NoPostsCell"
    struct Size {
        static let headerTop: CGFloat = 14
        static let bodyTop: CGFloat = 17
        static let labelInsets: CGFloat = 10
    }

    private let noPostsHeader = StyledLabel(style: .largeBold)
    private let noPostsBody = StyledLabel()

    var isCurrentUser: Bool = false {
        didSet { updateText() }
    }

    override func style() {
        noPostsHeader.textAlignment = .left
        noPostsBody.textAlignment = .left
    }

    override func arrange() {
        contentView.addSubview(noPostsHeader)
        contentView.addSubview(noPostsBody)

        noPostsHeader.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(Size.headerTop)
            make.leading.trailing.equalTo(contentView).inset(Size.labelInsets)
        }

        noPostsBody.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView).inset(Size.labelInsets)
            make.top.equalTo(noPostsHeader.snp.bottom).offset(Size.bodyTop)
        }
    }

    private func updateText() {
        let noPostsHeaderText: String
        let noPostsBodyText: String
        if isCurrentUser {
            noPostsHeaderText = InterfaceString.Profile.CurrentUserNoResultsTitle
            noPostsBodyText = InterfaceString.Profile.CurrentUserNoResultsBody
        }
        else {
            noPostsHeaderText = InterfaceString.Profile.NoResultsTitle
            noPostsBodyText = InterfaceString.Profile.NoResultsBody
        }

        noPostsHeader.text = noPostsHeaderText
        noPostsHeader.font = UIFont.regularBoldFont(18)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        let attrString = NSMutableAttributedString(
            string: noPostsBodyText,
            attributes: [
                .font: UIFont.defaultFont(),
                .paragraphStyle: paragraphStyle,
            ]
        )
        noPostsBody.attributedText = attrString
    }
}
