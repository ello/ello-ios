////
///  RelationshipControl.swift
//


enum RelationshipControlStyle {
    case `default`
    case profileView

    var starButtonMargin: CGFloat {
        switch self {
            case .profileView: return 10
            default: return 7
        }
    }

    var starButtonWidth: CGFloat {
        switch self {
            case .profileView: return 20
            default: return 30
        }
    }
}


class RelationshipControl: UIView {
    struct Size {
        static let viewHeight: CGFloat = 30
        static let minViewWidth: CGFloat = 105
    }

    let followingButton = FollowButton()
    let starButton = StarButton()
    var style: RelationshipControlStyle = .default {
        didSet {
            followingButton.relationshipStyle = style
            starButton.relationshipStyle = style
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }

    var enabled: Bool {
        set {
            followingButton.isEnabled = newValue
            starButton.isEnabled = newValue
        }
        get { return followingButton.isEnabled }
    }
    var userId: String
    var userAtName: String

    weak var relationshipDelegate: RelationshipDelegate?
    var relationshipPriority: RelationshipPriority = .none {
        didSet { updateRelationshipPriority() }
    }

    var showStarButton = true {
        didSet {
            starButton.isHidden = !showStarButton
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }

    required override init(frame: CGRect) {
        self.userId = ""
        self.userAtName = ""
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        self.userId = ""
        self.userAtName = ""
        super.init(coder: coder)
        setup()
    }

    fileprivate func setup() {
        arrange()
        bindActions()
        starButton.isHidden = !showStarButton
        updateRelationshipPriority()
        backgroundColor = .clear
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

        if showStarButton {
            totalSize.width += style.starButtonWidth + style.starButtonMargin
        }

        return totalSize
    }

    // MARK: IBActions

    @IBAction func starButtonTapped(_ sender: UIButton) {
        switch relationshipPriority {
        case .mute, .block:
            launchUnmuteModal()
        case .starred:
            handleUnstar()
        default:
            handleStar()
        }
    }

    @IBAction func followingButtonTapped(_ sender: UIButton) {
        switch relationshipPriority {
        case .mute, .block:
            launchUnmuteModal()
        case .following:
            handleUnfollow()
        case .starred:
            handleUnstar()
        default:
            handleFollow()
        }
    }

    fileprivate func launchUnmuteModal() {
        guard relationshipPriority.isMutedOrBlocked else {
            return
        }

        guard let relationshipDelegate = relationshipDelegate else {
            return
        }

        let prevRelationshipPriority = self.relationshipPriority
        relationshipDelegate.launchBlockModal(userId, userAtName: userAtName, relationshipPriority: prevRelationshipPriority) { newRelationshipPriority in
            self.relationshipPriority = newRelationshipPriority
        }
    }

    fileprivate func handleRelationship(_ newRelationshipPriority: RelationshipPriority) {
        guard let relationshipDelegate = relationshipDelegate else {
            return
        }

        self.isUserInteractionEnabled = false
        let prevRelationshipPriority = self.relationshipPriority
        self.relationshipPriority = newRelationshipPriority
        relationshipDelegate.relationshipTapped(self.userId, prev: prevRelationshipPriority, relationshipPriority: newRelationshipPriority) { (status, relationship, isFinalValue) in
            self.isUserInteractionEnabled = isFinalValue

            if let newRelationshipPriority = relationship?.subject?.relationshipPriority {
                self.relationshipPriority = newRelationshipPriority
            }
            else {
                self.relationshipPriority = prevRelationshipPriority
            }
        }
    }

    fileprivate func handleFollow() {
        handleRelationship(.following)
    }

    fileprivate func handleStar() {
        handleRelationship(.starred)
    }

    fileprivate func handleUnstar() {
        handleRelationship(.following)
    }

    fileprivate func handleUnfollow() {
        handleRelationship(.inactive)
    }

    // MARK: Private

    fileprivate func arrange() {
        addSubview(starButton)
        addSubview(followingButton)
    }

    fileprivate func bindActions() {
        followingButton.addTarget(self, action: #selector(RelationshipControl.followingButtonTapped(_:)), for: .touchUpInside)
        starButton.addTarget(self, action: #selector(RelationshipControl.starButtonTapped(_:)), for: .touchUpInside)
    }

    fileprivate func updateRelationshipPriority() {
        let config: Config
        switch relationshipPriority {
        case .following: config = .following
        case .starred: config = .starred
        case .mute: config = .muted
        case .block: config = .blocked
        default: config = .none
        }

        followingButton.config = config
        starButton.config = config
        starButton.isHidden = relationshipPriority.isMutedOrBlocked || !showStarButton

        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let starButtonWidth: CGFloat
        if !relationshipPriority.isMutedOrBlocked && showStarButton {
            starButton.frame = CGRect(x: frame.width - style.starButtonWidth, y: 0, width: style.starButtonWidth, height: Size.viewHeight)
            starButtonWidth = style.starButtonWidth + style.starButtonMargin
        }
        else {
            starButton.frame = .zero
            starButtonWidth = 0
        }

        followingButton.frame = bounds.inset(top: 0, left: 0, bottom: 0, right: starButtonWidth)
    }

    fileprivate enum Config {
        case starred
        case following
        case muted
        case blocked
        case none

        var title: String {
            switch self {
            case .none: return InterfaceString.Relationship.Follow
            case .following: return InterfaceString.Relationship.Following
            case .starred: return InterfaceString.Relationship.Starred
            case .muted: return InterfaceString.Relationship.Muted
            case .blocked: return InterfaceString.Relationship.Blocked
            }
        }

        var starred: Bool {
            return self == .starred
        }

        var image: UIImage? {
            switch self {
            case .muted, .blocked: return nil
            case .starred, .following: return InterfaceImage.checkSmall.whiteImage
            default: return InterfaceImage.plusSmall.selectedImage
            }
        }

        var highlightedImage: UIImage? {
            switch self {
            case .muted, .blocked, .starred, .following: return self.image
            default: return InterfaceImage.plusSmall.whiteImage
            }
        }
    }

    class FollowButton: StyledButton {
        var relationshipStyle: RelationshipControlStyle = .default {
            didSet { recalculateStyle() }
        }
        fileprivate var config: Config = .none {
            didSet { recalculateStyle() }
        }

        fileprivate func recalculateStyle() {
            let style: StyledButton.Style
            var image: UIImage? = nil
            var highlightedImage: UIImage? = nil

            if config == .following || config == .starred {
                if relationshipStyle == .profileView {
                    style = .GrayPill
                }
                else {
                    style = .BlackPill
                }
                image = InterfaceImage.checkSmall.whiteImage
                highlightedImage = image
            }
            else if config == .muted || config == .blocked {
                style = .RedPill
            }
            else if relationshipStyle == .profileView && config == .none {
                style = .GreenPill
                image = InterfaceImage.plusSmall.whiteImage
                highlightedImage = image
            }
            else {
                style = .BlackPillOutline
                image = InterfaceImage.plusSmall.selectedImage
                highlightedImage = InterfaceImage.plusSmall.whiteImage
            }

            setTitle(config.title, for: .normal)
            setImage(image, for: .normal)
            setImage(highlightedImage, for: .highlighted)
            setImage(UIImage(), for: .disabled)
            self.style = style
        }

        override func sharedSetup() {
            super.sharedSetup()
            contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 10)
            adjustsImageWhenDisabled = false
            recalculateStyle()
        }
    }

    class StarButton: StyledButton {
        var relationshipStyle: RelationshipControlStyle = .default {
            didSet { recalculateStyle() }
        }
        fileprivate var config: Config = .none {
            didSet { recalculateStyle() }
        }

        fileprivate func recalculateStyle() {
            var image: UIImage? = nil
            var highlightedImage: UIImage? = nil

            if config == .starred {
                if relationshipStyle == .profileView {
                    image = InterfaceImage.whiteStar.selectedImage
                }
                else {
                    image = InterfaceImage.blackStar.selectedImage
                }
                highlightedImage = image
            }
            else if relationshipStyle == .profileView {
                image = InterfaceImage.whiteStar.normalImage
                highlightedImage = InterfaceImage.whiteStar.selectedImage
            }
            else {
                image = InterfaceImage.blackStar.normalImage
                highlightedImage = InterfaceImage.blackStar.selectedImage
            }

            setImage(image, for: .normal)
            setImage(highlightedImage, for: .highlighted)
            setImage(UIImage(), for: .disabled)
        }

        override func sharedSetup() {
            super.sharedSetup()

            adjustsImageWhenDisabled = false
            config = .none
            style = .ClearWhite
            recalculateStyle()
        }
    }
}
