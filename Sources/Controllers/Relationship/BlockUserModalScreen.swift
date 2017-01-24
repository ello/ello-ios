////
///  BlockUserModalScreen.swift
//

import SnapKit

protocol BlockUserModalDelegate {
    func updateRelationship(_ newRelationship: RelationshipPriority)
    func flagTapped()
    func closeModal()
}

class BlockUserModalScreen: UIView {
    struct Size {
        static let outerMargins = UIEdgeInsets(top: 50, left: 10, bottom: 0, right: 10)
        static let innerMargins = UIEdgeInsets(all: 20)
        static let buttonTopMargin: CGFloat = 40
        static let buttonHeight: CGFloat = 50
        static let labelTopMargin: CGFloat = 20
        static let closeButtonSize: CGFloat = 30
    }

    fileprivate let backgroundButton = UIButton()
    fileprivate let modalView = UIScrollView()
    fileprivate let innerView = UIView()
    fileprivate let closeButton = UIButton()
    fileprivate let titleLabel = UILabel()
    fileprivate let muteButton = StyledButton(style: .White)
    fileprivate let muteLabel = UILabel()
    fileprivate let blockButton = StyledButton(style: .White)
    fileprivate let blockLabel = UILabel()
    fileprivate let flagButton = StyledButton(style: .White)
    fileprivate let flagLabel = UILabel()

    fileprivate var delegate: BlockUserModalDelegate? {
        get { return next as? BlockUserModalDelegate }
    }

    required init(config: BlockUserModalConfig) {
        super.init(frame: .zero)

        style()
        bindActions()
        setText()
        arrange()
        setDetails(userAtName: config.userAtName, relationshipPriority: config.relationshipPriority)
    }

    required override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setDetails(userAtName: String, relationshipPriority: RelationshipPriority) {
        let titleText: String
        switch relationshipPriority {
        case .mute: titleText = String(format: InterfaceString.Relationship.UnmuteAlertTemplate, userAtName)
        case .block: titleText = String(format: InterfaceString.Relationship.BlockAlertTemplate, userAtName)
        default: titleText = String(format: InterfaceString.Relationship.MuteAlertTemplate, userAtName)
        }

        let muteText = String(format: InterfaceString.Relationship.MuteWarningTemplate, userAtName, userAtName)
        let blockText = String(format: InterfaceString.Relationship.BlockWarningTemplate, userAtName)
        let flagText = String(format: InterfaceString.Relationship.BlockWarningTemplate, userAtName)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        let labels: [(UILabel, String)] = [(titleLabel, titleText), (muteLabel, muteText), (blockLabel, blockText), (flagLabel, flagText)]
        for (label, text) in labels {
            label.attributedText = NSAttributedString(string: text, attributes: [
                NSParagraphStyleAttributeName: paragraphStyle
            ])
        }

        resetButtons()
        switch relationshipPriority {
        case .mute:
            muteButton.isSelected = true
        case .block:
            blockButton.isSelected = true
        default:
            break
        }
    }

    fileprivate func resetButtons() {
        muteButton.isSelected = false
        blockButton.isSelected = false
    }
}

// MARK: STYLING

extension BlockUserModalScreen {
    fileprivate func style() {
        backgroundButton.backgroundColor = UIColor.modalBackground()
        modalView.backgroundColor = UIColor.red
        for label in [titleLabel, muteLabel, blockLabel, flagLabel] {
            styleLabel(label)
        }
        for button in [muteButton, blockButton, flagButton] {
            styleButton(button)
        }
        closeButton.setImages(.x, white: true)
    }

    fileprivate func styleLabel(_ label: UILabel) {
        label.font = .defaultFont()
        label.textColor = .white
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
    }

    fileprivate func styleButton(_ button: UIButton) {
        button.backgroundColor = .white
        button.titleLabel?.font = .defaultFont()
        button.titleLabel?.textColor = .white
    }
}

extension BlockUserModalScreen {
    fileprivate func bindActions() {
        backgroundButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        blockButton.addTarget(self, action: #selector(blockTapped(_:)), for: .touchUpInside)
        muteButton.addTarget(self, action: #selector(muteTapped(_:)), for: .touchUpInside)
        flagButton.addTarget(self, action: #selector(flagTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
    }

// MARK: ACTIONS

    func blockTapped(_ sender: UIButton) {
        let relationshipPriority: RelationshipPriority
        if sender.isSelected == true {
            relationshipPriority = .inactive
        } else {
            relationshipPriority = .block
        }
        delegate?.updateRelationship(relationshipPriority)
    }

    func muteTapped(_ sender: UIButton) {
        let relationshipPriority: RelationshipPriority
        if sender.isSelected == true {
            relationshipPriority = .inactive
        } else {
            relationshipPriority = .mute
        }
        delegate?.updateRelationship(relationshipPriority)
    }

    func flagTapped() {
        delegate?.flagTapped()
    }

    func closeModal() {
        delegate?.closeModal()
    }
}

extension BlockUserModalScreen {
    fileprivate func setText() {
        muteButton.setTitle(InterfaceString.Relationship.MuteButton, for: .normal)
        blockButton.setTitle(InterfaceString.Relationship.BlockButton, for: .normal)
        flagButton.setTitle(InterfaceString.Relationship.FlagButton, for: .normal)
    }
}

extension BlockUserModalScreen {
    override func layoutSubviews() {
        super.layoutSubviews()

        let modalWidth = frame.width - Size.outerMargins.left - Size.outerMargins.right
        let innerWidth = modalWidth - Size.innerMargins.left - Size.innerMargins.right
        let titleWidth = innerWidth - Size.closeButtonSize - Size.innerMargins.right
        titleLabel.preferredMaxLayoutWidth = titleWidth
        muteLabel.preferredMaxLayoutWidth = innerWidth
        blockLabel.preferredMaxLayoutWidth = innerWidth
        flagLabel.preferredMaxLayoutWidth = innerWidth

        closeButton.frame = CGRect(
            x: innerWidth - Size.closeButtonSize,
            y: 0,
            width: Size.closeButtonSize, height: Size.closeButtonSize
            )
        titleLabel.frame = CGRect(
            x: 0, y: 0,
            width: titleWidth,
            height: 10
            )
        titleLabel.sizeToFit()

        var y: CGFloat = titleLabel.frame.maxY
        for (button, label) in [(muteButton, muteLabel), (blockButton, blockLabel), (flagButton, flagLabel)] {
            for view in [button, label] {
                view.frame.origin.x = 0
                view.frame.size.width = innerWidth
            }

            y += Size.buttonTopMargin
            button.frame.origin.y = y
            button.frame.size.height = Size.buttonHeight
            y += button.frame.height + Size.labelTopMargin
            label.frame.origin.y = y
            label.sizeToFit()
            y += label.frame.height
        }

        y += Size.innerMargins.bottom
        let innerFrame = CGRect(
            x: Size.innerMargins.left,
            y: Size.innerMargins.top,
            width: innerWidth, height: y)
        innerView.frame = innerFrame

        modalView.contentSize = CGSize(width: modalWidth, height: innerFrame.maxY)
        let bestScrollHeight: CGFloat = modalView.contentSize.height
        let maxScrollHeight = frame.height - Size.outerMargins.top
        modalView.frame = CGRect(
            x: Size.outerMargins.left,
            y: Size.outerMargins.top,
            width: modalWidth, height: min(bestScrollHeight, maxScrollHeight)
            )
    }

    fileprivate func arrange() {
        addSubview(backgroundButton)
        addSubview(modalView)

        modalView.addSubview(innerView)
        let innerViews: [UIView] = [closeButton, titleLabel, muteButton, muteLabel, blockButton, blockLabel, flagButton, flagLabel]
        for view in innerViews {
            innerView.addSubview(view)
        }

        backgroundButton.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }

}
