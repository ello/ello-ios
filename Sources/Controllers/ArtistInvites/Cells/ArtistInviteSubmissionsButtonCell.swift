////
///  ArtistInviteSubmissionsButtonCell.swift
//

import SnapKit


class ArtistInviteSubmissionsButtonCell: CollectionViewCell {
    static let reuseIdentifier = "ArtistInviteSubmissionsButtonCell"

    struct Size {
        static let height: CGFloat = 70
        static let buttonMargins = UIEdgeInsets(top: 0, left: 15, bottom: 30, right: 15)
    }

    private let submissionsButton = StyledButton(style: .artistInviteSubmissions)

    override func style() {
        submissionsButton.titleEdgeInsets.top = 4
    }

    override func bindActions() {
        submissionsButton.addTarget(self, action: #selector(tappedSubmissionsButton), for: .touchUpInside)
    }

    override func setText() {
        submissionsButton.title = InterfaceString.ArtistInvites.SeeSubmissions
    }

    override func arrange() {
        contentView.addSubview(submissionsButton)

        submissionsButton.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(Size.buttonMargins)
        }
    }
}

extension ArtistInviteSubmissionsButtonCell {
    @objc
    func tappedSubmissionsButton() {
        let responder: ArtistInviteResponder? = findResponder()
        responder?.tappedArtistInviteSubmissionsButton()
    }
}

extension StyledButton.Style {
    static let artistInviteSubmissions = StyledButton.Style(
        backgroundColor: .white, highlightedBackgroundColor: .greenD1,
        titleColor: .greenD1, highlightedTitleColor: .white,
        borderColor: .greenD1, highlightedBorderColor: .white,
        cornerRadius: .rounded
        )
}
