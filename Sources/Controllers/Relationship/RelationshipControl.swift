////
///  RelationshipControl.swift
//


enum RelationshipControlUsage {
    case `default`
    case profileView
}


class RelationshipControl: View {
    struct Size {
        static let viewHeight: CGFloat = 30
        static let minViewWidth: CGFloat = 105
    }

    let followingButton = FollowButton()

    var usage: RelationshipControlUsage = .default {
        didSet {
            followingButton.relationshipUsage = usage
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }

    var isEnabled: Bool {
        set {
            followingButton.isEnabled = newValue
        }
        get { return followingButton.isEnabled }
    }
    var userId: String = ""
    var userAtName: String = ""

    var relationshipPriority: RelationshipPriority = .none {
        didSet { updateRelationshipPriority() }
    }

    override var intrinsicContentSize: CGSize {
        var totalSize = CGSize(width: 0, height: Size.viewHeight)
        let followingSize = followingButton.intrinsicContentSize
        if followingSize.width > Size.minViewWidth {
            totalSize.width += followingSize.width
        }
        else {
            totalSize.width += Size.minViewWidth
        }

        return totalSize
    }

    override func style() {
        updateRelationshipPriority()
        backgroundColor = .clear
    }

    override func bindActions() {
        followingButton.addTarget(
            self,
            action: #selector(RelationshipControl.followingButtonTapped(_:)),
            for: .touchUpInside
        )
    }

    override func arrange() {
        addSubview(followingButton)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        followingButton.frame = bounds
    }

    fileprivate enum Config {
        case following
        case muted
        case blocked
        case none
    }

    class FollowButton: StyledButton {
        var relationshipUsage: RelationshipControlUsage = .default {
            didSet { restyleUsage() }
        }
        fileprivate var config: Config = .none {
            didSet { restyleUsage() }
        }

        override func sharedSetup() {
            super.sharedSetup()
            contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 10)
            adjustsImageWhenDisabled = false
            restyleUsage()
        }
    }
}

extension RelationshipControl {

    @IBAction
    func followingButtonTapped(_ sender: UIButton) {
        switch relationshipPriority {
        case .mute, .block:
            launchUnmuteModal()
        case .following:
            handleUnfollow()
        default:
            handleFollow()
        }
    }

    private func launchUnmuteModal() {
        guard relationshipPriority.isMutedOrBlocked else {
            return
        }

        let prevRelationshipPriority = RelationshipPriorityWrapper(
            priority: self.relationshipPriority
        )

        let responder: RelationshipResponder? = findResponder()
        responder?.launchBlockModal(
            userId,
            userAtName: userAtName,
            relationshipPriority: prevRelationshipPriority
        ) { [weak self] newRelationshipPriority in
            guard let `self` = self else { return }
            self.relationshipPriority = newRelationshipPriority.priority
        }
    }

    private func handleFollow() {
        handleRelationship(.following)
    }

    private func handleUnfollow() {
        handleRelationship(.inactive)
    }

    private func handleRelationship(_ newRelationshipPriority: RelationshipPriority) {
        self.isUserInteractionEnabled = false
        let prevRelationshipPriority = RelationshipPriorityWrapper(
            priority: self.relationshipPriority
        )
        self.relationshipPriority = newRelationshipPriority

        let responder: RelationshipResponder? = findResponder()
        responder?.relationshipTapped(
            self.userId,
            prev: prevRelationshipPriority,
            relationshipPriority: RelationshipPriorityWrapper(priority: newRelationshipPriority)
        ) { [weak self] status, relationship, isFinalValue in
            guard let `self` = self else { return }
            self.isUserInteractionEnabled = isFinalValue

            if let newRelationshipPriority = relationship?.subject?.relationshipPriority {
                self.relationshipPriority = newRelationshipPriority
            }
            else {
                self.relationshipPriority = prevRelationshipPriority.priority
            }
        }
    }

}

extension RelationshipControl {
    private func updateRelationshipPriority() {
        let config: Config
        switch relationshipPriority {
        case .following: config = .following
        case .mute: config = .muted
        case .block: config = .blocked
        default: config = .none
        }

        followingButton.config = config

        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }
}

extension RelationshipControl.Config {
    var title: String {
        switch self {
        case .none: return InterfaceString.Relationship.Follow
        case .following: return InterfaceString.Relationship.Following
        case .muted: return InterfaceString.Relationship.Muted
        case .blocked: return InterfaceString.Relationship.Blocked
        }
    }


    var image: UIImage? {
        switch self {
        case .muted, .blocked: return nil
        case .following: return InterfaceImage.checkSmall.whiteImage
        default: return InterfaceImage.plusSmall.selectedImage
        }
    }

    var highlightedImage: UIImage? {
        switch self {
        case .muted, .blocked, .following: return self.image
        default: return InterfaceImage.plusSmall.whiteImage
        }
    }
}

extension RelationshipControl.FollowButton {
    private func restyleUsage() {
        let style: StyledButton.Style
        var image: UIImage?
        var highlightedImage: UIImage?

        if config == .following {
            if relationshipUsage == .profileView {
                style = .grayPill
            }
            else {
                style = .blackPill
            }
            image = InterfaceImage.checkSmall.whiteImage
            highlightedImage = image
        }
        else if config == .muted || config == .blocked {
            style = .redPill
        }
        else if relationshipUsage == .profileView && config == .none {
            style = .greenPill
            image = InterfaceImage.plusSmall.whiteImage
            highlightedImage = image
        }
        else {
            style = .blackPillOutline
            image = InterfaceImage.plusSmall.selectedImage
            highlightedImage = InterfaceImage.plusSmall.whiteImage
        }

        setTitle(config.title, for: .normal)
        setImage(image, for: .normal)
        setImage(highlightedImage, for: .highlighted)
        setImage(UIImage(), for: .disabled)
        self.style = style
    }
}
