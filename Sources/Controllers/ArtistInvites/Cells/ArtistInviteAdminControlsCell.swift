////
///  ArtistInviteAdminControlsCell.swift
//

import SnapKit


class ArtistInviteAdminControlsCell: CollectionViewCell {
    static let reuseIdentifier = "ArtistInviteAdminControlsCell"

    struct Size {
        static let height: CGFloat = 40
        static let buttonSpacing: CGFloat = 20
    }

    struct Config {
        var actions: [ArtistInviteSubmission.Action] = []
    }

    var config = Config() {
        didSet {
            updateConfig()
        }
    }

    private let buttonContainer = Container()
    private var buttons: [StyledButton] = []

    override func style() {
        contentView.backgroundColor = .greyF2
    }

    override func arrange() {
        contentView.addSubview(buttonContainer)

        buttonContainer.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView)
            make.centerX.equalTo(contentView)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        config = Config()
    }

    func updateConfig() {
        for button in buttons {
            button.removeFromSuperview()
        }

        buttons = config.actions.map { action -> StyledButton in
            let button = StyledButton()
            button.title = action.buttonTitle
            button.setImage(action.buttonImage, for: .normal)
            button.addTarget(self, action: #selector(tappedButton(_:)), for: .touchUpInside)

            switch action.name {
            case .unapprove: button.style = .clearGreen
            case .unselect: button.style = .clearOrange
            default: button.style = .clearGray
            }

            return button
        }

        buttons.eachPair { prevButton, button, isLast in
            contentView.addSubview(button)
            button.snp.makeConstraints { make in
                make.centerY.equalTo(buttonContainer)

                if let prevButton = prevButton {
                    make.leading.equalTo(prevButton.snp.trailing).offset(Size.buttonSpacing)
                }
                else {
                    make.leading.equalTo(buttonContainer)
                }

                if isLast {
                    make.trailing.equalTo(buttonContainer)
                }
            }
        }
    }
}

extension ArtistInviteAdminControlsCell {
    @objc
    func tappedButton(_ sender: StyledButton) {
        guard
            let index = buttons.firstIndex(of: sender),
            let action = config.actions.safeValue(index)
        else { return }

        let responder: ArtistInviteAdminResponder? = findResponder()
        responder?.tappedArtistInviteAction(cell: self, action: action)
    }
}

extension ArtistInviteAdminControlsCell.Config {
    static func from(submission: ArtistInviteSubmission) -> ArtistInviteAdminControlsCell.Config {
        var config = ArtistInviteAdminControlsCell.Config()
        config.actions = submission.actions
        return config
    }
}

extension ArtistInviteSubmission.Action {
    var buttonTitle: String {
        switch name {
        case .approve: return InterfaceString.ArtistInvites.AdminApproveAction
        case .unapprove: return InterfaceString.ArtistInvites.AdminUnapproveAction
        case .unselect: return InterfaceString.ArtistInvites.AdminUnselectAction
        case .decline: return InterfaceString.ArtistInvites.AdminDeclineAction
        default: return NSLocalizedString(label ?? "", comment: "")
        }
    }

    var buttonImage: UIImage? {
        switch name {
        case .unapprove: return InterfaceImage.circleCheck.greenImage
        case .unselect: return InterfaceImage.star.orangeImage
        case .approve: return InterfaceImage.circleCheck.normalImage
        case .select: return InterfaceImage.star.normalImage
        case .decline: return InterfaceImage.xBox.normalImage
        default: return nil
        }
    }
}
