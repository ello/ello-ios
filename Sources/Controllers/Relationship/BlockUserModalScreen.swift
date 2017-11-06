////
///  BlockUserModalScreen.swift
//

import SnapKit

protocol BlockUserModalDelegate: class {
    func updateRelationship(_ newRelationship: RelationshipPriority)
    func flagTapped()
    func closeModal()
}

class BlockUserModalScreen: View {
    struct Size {
        static let outerMargins = UIEdgeInsets(top: 50, left: 10, bottom: 0, right: 10)
        static let innerMargins = UIEdgeInsets(all: 20)
        static let buttonTopMargin: CGFloat = 40
        static let buttonHeight: CGFloat = 50
        static let labelTopMargin: CGFloat = 20
        static let closeButtonSize: CGFloat = 30
    }

    private let backgroundButton = UIButton()
    private let modalView = UIScrollView()
    private let innerView = UIView()
    private let closeButton = UIButton()
    private let titleLabel = UILabel()
    private let muteButton = StyledButton(style: .white)
    private let muteLabel = UILabel()
    private let blockButton = StyledButton(style: .white)
    private let blockLabel = UILabel()
    private let flagButton = StyledButton(style: .white)
    private let flagLabel = UILabel()

    private var delegate: BlockUserModalDelegate? {
        return next as? BlockUserModalDelegate
    }

    convenience init(config: BlockUserModalConfig) {
        self.init(frame: .zero)
        setDetails(userAtName: config.userAtName, relationshipPriority: config.relationshipPriority)
    }

    override func style() {
        backgroundButton.backgroundColor = UIColor.dimmedModalBackground
        modalView.backgroundColor = UIColor.red
        for label in [titleLabel, muteLabel, blockLabel, flagLabel] {
            styleLabel(label)
        }
        for button in [muteButton, blockButton, flagButton] {
            styleButton(button)
        }
        closeButton.setImages(.x, white: true)
    }

    override func bindActions() {
        backgroundButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        blockButton.addTarget(self, action: #selector(blockTapped(_:)), for: .touchUpInside)
        muteButton.addTarget(self, action: #selector(muteTapped(_:)), for: .touchUpInside)
        flagButton.addTarget(self, action: #selector(flagTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
    }

    override func setText() {
        muteButton.setTitle(InterfaceString.Relationship.MuteButton, for: .normal)
        blockButton.setTitle(InterfaceString.Relationship.BlockButton, for: .normal)
        flagButton.setTitle(InterfaceString.Relationship.FlagButton, for: .normal)
    }

    override func arrange() {
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

extension BlockUserModalScreen {
    private func setDetails(userAtName: String, relationshipPriority: RelationshipPriority) {
        let titleText: String
        switch relationshipPriority {
        case .mute: titleText = InterfaceString.Relationship.UnmuteAlert(atName: userAtName)
        case .block: titleText = InterfaceString.Relationship.UnblockAlert(atName: userAtName)
        default: titleText = InterfaceString.Relationship.MuteAlert(atName: userAtName)
        }

        let muteText = InterfaceString.Relationship.MuteWarning(atName: userAtName)
        let blockText = InterfaceString.Relationship.BlockWarning(atName: userAtName)
        let flagText = InterfaceString.Relationship.FlagWarning(atName: userAtName)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        let labels: [(UILabel, String)] = [(titleLabel, titleText), (muteLabel, muteText), (blockLabel, blockText), (flagLabel, flagText)]
        for (label, text) in labels {
            label.attributedText = NSAttributedString(string: text, attributes: [.paragraphStyle: paragraphStyle])
        }

        resetButtons()
        switch relationshipPriority {
        case .mute:
            muteButton.setTitle(InterfaceString.Relationship.UnmuteButton, for: .normal)
            muteButton.isSelected = true
        case .block:
            blockButton.setTitle(InterfaceString.Relationship.UnblockButton, for: .normal)
            blockButton.isSelected = true
        default:
            break
        }
    }

    private func resetButtons() {
        muteButton.setTitle(InterfaceString.Relationship.MuteButton, for: .normal)
        blockButton.setTitle(InterfaceString.Relationship.BlockButton, for: .normal)
        muteButton.isSelected = false
        blockButton.isSelected = false
    }

    private func styleLabel(_ label: UILabel) {
        label.font = .defaultFont()
        label.textColor = .white
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
    }

    private func styleButton(_ button: UIButton) {
        button.backgroundColor = .white
        button.titleLabel?.font = .defaultFont()
        button.titleLabel?.textColor = .white
    }
}

// MARK: ACTIONS
extension BlockUserModalScreen {

    @objc
    func blockTapped(_ sender: UIButton) {
        let relationshipPriority: RelationshipPriority
        if sender.isSelected == true {
            relationshipPriority = .inactive
        } else {
            relationshipPriority = .block
        }
        delegate?.updateRelationship(relationshipPriority)
    }

    @objc
    func muteTapped(_ sender: UIButton) {
        let relationshipPriority: RelationshipPriority
        if sender.isSelected == true {
            relationshipPriority = .inactive
        } else {
            relationshipPriority = .mute
        }
        delegate?.updateRelationship(relationshipPriority)
    }

    @objc
    func flagTapped() {
        delegate?.flagTapped()
    }

    @objc
    func closeModal() {
        delegate?.closeModal()
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

}
