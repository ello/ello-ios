////
///  ArtistInviteSubmissionSuccessScreen.swift
//

class ArtistInviteSubmissionSuccessScreen: Screen {
    struct Size {
        static let margins: CGFloat = 15
        static let textSpacing: CGFloat = 24
    }

    private let textContainer = Container()
    private let titleLabel = StyledLabel(style: .submissionSuccessTitle)
    private let descriptionLabel = StyledLabel(style: .submissionSuccessDescription)

    override func setText() {
        titleLabel.text = InterfaceString.ArtistInvites.SubmissionSuccessTitle
        descriptionLabel.text = InterfaceString.ArtistInvites.SubmissionSuccessDescription
        descriptionLabel.isMultiline = true
    }

    override func arrange() {
        addSubview(textContainer)
        textContainer.addSubview(titleLabel)
        textContainer.addSubview(descriptionLabel)

        textContainer.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(Size.margins)
            make.centerY.equalTo(self)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(textContainer)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Size.textSpacing)
            make.bottom.leading.trailing.equalTo(textContainer)
        }
    }
}

extension StyledLabel.Style {
    static let submissionSuccessTitle = StyledLabel.Style(
        textColor: .greenD1,
        fontFamily: .artistInviteTitle
        )
    static let submissionSuccessDescription = StyledLabel.Style(
        textColor: .greyA,
        fontFamily: .artistInviteTitle
        )
}
