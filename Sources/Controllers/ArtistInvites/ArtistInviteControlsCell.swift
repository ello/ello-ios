////
///  ArtistInviteControlsCell.swift
//

import SnapKit


class ArtistInviteControlsCell: CollectionViewCell, ArtistInviteConfigurableCell {
    static let reuseIdentifier = "ArtistInviteControlsCell"

    struct Size {
        static let controlsHeight: CGFloat = 130
        static let loggedOutControlsHeight: CGFloat = 50

        static let margins = UIEdgeInsets(top: 0, left: 15, bottom: 60, right: 15)
        static let submitHeight: CGFloat = 80
    }

    typealias Config = ArtistInviteBubbleCell.Config

    var config = Config() {
        didSet {
            updateConfig()
        }
    }

    fileprivate let descriptionWebView = ElloWebView()
    fileprivate let submitButton = StyledButton(style: .artistInviteSubmit)
    fileprivate var submitVisibleConstraint: Constraint!
    fileprivate var submitHiddenConstraint: Constraint!

    override func style() {
        descriptionWebView.scrollView.isScrollEnabled = false
        descriptionWebView.scrollView.scrollsToTop = false
    }

    override func bindActions() {
        submitButton.addTarget(self, action: #selector(tappedSubmitButton), for: .touchUpInside)
    }

    override func setText() {
        submitButton.title = InterfaceString.ArtistInvites.Submit
    }

    override func arrange() {
        contentView.addSubview(descriptionWebView)
        contentView.addSubview(submitButton)

        descriptionWebView.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            submitVisibleConstraint = make.bottom.equalTo(submitButton.snp.top).constraint
            submitHiddenConstraint = make.bottom.equalTo(contentView).constraint
            make.leading.trailing.equalTo(contentView).inset(Size.margins)
        }
        submitHiddenConstraint.deactivate()

        submitButton.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(contentView).inset(Size.margins)
            make.height.equalTo(Size.submitHeight)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        config = Config()
    }

    func updateConfig() {
        let html = StreamTextCellHTML.postHTML(config.longDescription)
        descriptionWebView.loadHTMLString(html, baseURL: URL(string: "/"))

        let isOpen = config.status == .open

        if config.hasCurrentUser && isOpen {
            submitVisibleConstraint.activate()
            submitHiddenConstraint.deactivate()
            submitButton.isHidden = false
        }
        else {
            submitVisibleConstraint.deactivate()
            submitHiddenConstraint.activate()
            submitButton.isHidden = true
        }
    }
}

extension ArtistInviteControlsCell {
    @objc
    func tappedSubmitButton() {
        let responder: ArtistInviteResponder? = findResponder()
        responder?.tappedArtistInviteSubmitButton()
    }
}

extension StyledButton.Style {
    static let artistInviteSubmit = StyledButton.Style(
        backgroundColor: .greenD1,
        titleColor: .white, highlightedTitleColor: .black,
        font: .regularLightFont(24),
        cornerRadius: .rounded
        )
}
