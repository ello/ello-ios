////
///  RelationshipControl.swift
//

private let ViewHeight: CGFloat = 30
private let MinViewWidth: CGFloat = 105


public enum RelationshipControlStyle {
    case Default
    case ProfileView

    var starButtonMargin: CGFloat {
        switch self {
            case .ProfileView: return 10
            default: return 7
        }
    }

    var starButtonWidth: CGFloat {
        switch self {
            case .ProfileView: return 50
            default: return 30
        }
    }
}


public class RelationshipControl: UIView {
    let followingButton = FollowButton()
    let starButton = StarButton()
    var style: RelationshipControlStyle = .Default {
        didSet {
            starButton.style = style
        }
    }

    public var enabled: Bool {
        set {
            followingButton.enabled = newValue
            starButton.enabled = newValue
        }
        get { return followingButton.enabled }
    }
    public var userId: String
    public var userAtName: String

    public weak var relationshipDelegate: RelationshipDelegate?
    public var relationshipPriority: RelationshipPriority = .None {
        didSet { updateRelationshipPriority() }
    }

    public var showStarButton = true {
        didSet {
            starButton.hidden = !showStarButton
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }

    required public override init(frame: CGRect) {
        self.userId = ""
        self.userAtName = ""
        super.init(frame: frame)
        setup()
    }

    required public init?(coder: NSCoder) {
        self.userId = ""
        self.userAtName = ""
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubviews()
        addTargets()
        starButton.hidden = !showStarButton
        updateRelationshipPriority()
        backgroundColor = .clearColor()
    }

    public override func intrinsicContentSize() -> CGSize {
        var totalSize = CGSize(width: 0, height: ViewHeight)
        let followingSize = followingButton.intrinsicContentSize()
        if followingSize.width > MinViewWidth {
            totalSize.width += followingSize.width
        }
        else {
            totalSize.width += MinViewWidth
        }

        if showStarButton {
            totalSize.width += style.starButtonWidth + style.starButtonMargin
        }

        return totalSize
    }

    // MARK: IBActions

    @IBAction func starButtonTapped(sender: UIButton) {
        switch relationshipPriority {
        case .Mute, .Block:
            launchUnmuteModal()
        case .Starred:
            handleUnstar()
        default:
            handleStar()
        }
    }

    @IBAction func followingButtonTapped(sender: UIButton) {
        switch relationshipPriority {
        case .Mute, .Block:
            launchUnmuteModal()
        case .Following:
            handleUnfollow()
        case .Starred:
            handleUnstar()
        default:
            handleFollow()
        }
    }

    private func launchUnmuteModal() {
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

    private func handleRelationship(newRelationshipPriority: RelationshipPriority) {
        guard let relationshipDelegate = relationshipDelegate else {
            return
        }

        self.userInteractionEnabled = false
        let prevRelationshipPriority = self.relationshipPriority
        self.relationshipPriority = newRelationshipPriority
        relationshipDelegate.relationshipTapped(self.userId, prev: prevRelationshipPriority, relationshipPriority: newRelationshipPriority) { (status, relationship, isFinalValue) in
            self.userInteractionEnabled = isFinalValue

            if let newRelationshipPriority = relationship?.subject?.relationshipPriority {
                self.relationshipPriority = newRelationshipPriority
            }
            else {
                self.relationshipPriority = prevRelationshipPriority
            }
        }
    }

    private func handleFollow() {
        handleRelationship(.Following)
    }

    private func handleStar() {
        handleRelationship(.Starred)
    }

    private func handleUnstar() {
        handleRelationship(.Following)
    }

    private func handleUnfollow() {
        handleRelationship(.Inactive)
    }

    // MARK: Private
    private func addSubviews() {
        addSubview(starButton)
        addSubview(followingButton)
    }

    private func addTargets() {
        followingButton.addTarget(self, action: #selector(RelationshipControl.followingButtonTapped(_:)), forControlEvents: .TouchUpInside)
        starButton.addTarget(self, action: #selector(RelationshipControl.starButtonTapped(_:)), forControlEvents: .TouchUpInside)
    }

    private func updateRelationshipPriority() {
        let config: Config
        switch relationshipPriority {
        case .Following: config = .Following
        case .Starred: config = .Starred
        case .Mute: config = .Muted
        case .Block: config = .Blocked
        default: config = .None
        }

        followingButton.config = config
        starButton.config = config
        starButton.hidden = relationshipPriority.isMutedOrBlocked || !showStarButton

        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        let starButtonWidth: CGFloat

        if !relationshipPriority.isMutedOrBlocked && showStarButton {
            starButton.frame = CGRect(x: frame.width - style.starButtonWidth, y: 0, width: style.starButtonWidth, height: ViewHeight)
            starButtonWidth = style.starButtonWidth + style.starButtonMargin
        }
        else {
            starButton.frame = .zero
            starButtonWidth = 0
        }

        followingButton.frame = bounds.inset(top: 0, left: 0, bottom: 0, right: starButtonWidth)
    }

    private enum Config {
        case Starred
        case Following
        case Muted
        case Blocked
        case None

        var title: String {
            switch self {
            case .None: return InterfaceString.Relationship.Follow
            case .Following: return InterfaceString.Relationship.Following
            case .Starred: return InterfaceString.Relationship.Starred
            case .Muted: return InterfaceString.Relationship.Muted
            case .Blocked: return InterfaceString.Relationship.Blocked
            }
        }

        var starred: Bool {
            switch self {
            case .Starred: return true
            default: return false
            }
        }

        var normalTextColor: UIColor {
            switch self {
            case .None: return .blackColor()
            default: return .whiteColor()
            }
        }

        var highlightedTextColor: UIColor {
            return .whiteColor()
        }

        var borderColor: UIColor {
            switch self {
            case .Muted, .Blocked: return .redColor()
            default: return .blackColor()
            }
        }

        var normalBackgroundColor: UIColor {
            switch self {
            case .Muted, .Blocked: return .redColor()
            case .None: return UIColor.clearColor()
            default: return .blackColor()
            }
        }

        var starBackgroundColor: UIColor {
            switch self {
            case .Starred: return UIColor.blackColor()
            default: return .clearColor()
            }
        }

        var selectedBackgroundColor: UIColor {
            switch self {
            case .Muted, .Blocked: return UIColor.redFFCCCC()
            case .None: return .blackColor()
            default: return .grey4D()
            }
        }

        var image: UIImage? {
            switch self {
            case .Muted, .Blocked: return nil
            case .Starred, .Following: return InterfaceImage.CheckSmall.whiteImage
            default: return InterfaceImage.PlusSmall.selectedImage
            }
        }

        var highlightedImage: UIImage? {
            switch self {
            case .Muted, .Blocked, .Starred, .Following: return self.image
            default: return InterfaceImage.PlusSmall.whiteImage
            }
        }
    }

    class FollowButton: RoundedElloButton {
        private var config: Config = .None {
            didSet {
                setTitleColor(config.normalTextColor, forState: .Normal)
                setTitleColor(config.highlightedTextColor, forState: .Highlighted)
                setTitleColor(UIColor.greyC(), forState: .Disabled)
                setTitle("", forState: .Disabled)
                setTitle(config.title, forState: .Normal)
                setImage(config.image, forState: .Normal)
                setImage(config.highlightedImage, forState: .Highlighted)
                borderColor = config.borderColor
                backgroundColor = config.normalBackgroundColor
            }
        }


        override func sharedSetup() {
            super.sharedSetup()
            contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 10)
            setImage(.PlusSmall, imageStyle: .Selected, forState: .Normal)

            adjustsImageWhenDisabled = false
            setImage(UIImage(), forState: .Disabled)

            config = .None
            backgroundColor = config.normalBackgroundColor
            borderColor = UIColor.greyE5()
        }

        override func updateOutline() {
            super.updateOutline()
            if enabled {
                backgroundColor = highlighted ? config.selectedBackgroundColor : config.normalBackgroundColor
            }
        }
    }

    class StarButton: RoundedElloButton {
        var style: RelationshipControlStyle = .Default {
            didSet {
                updateStyle()
            }
        }

        private var config: Config = .None {
            didSet {
                updateOutline()
                updateStyle()
            }
        }

        override func sharedSetup() {
            super.sharedSetup()

            adjustsImageWhenDisabled = false
            setImage(UIImage(), forState: .Disabled)

            config = .None
            updateStyle()
        }

        override func updateStyle() {
            super.updateStyle()

            let selected = config.starred
            let backgroundColor: UIColor
            switch style {
                case .ProfileView:
                    if selected {
                        setImage(.Star, imageStyle: .White, forState: .Normal)
                    }
                    else {
                        setImage(.Star, imageStyle: .Normal, forState: .Normal)
                    }
                    setImage(.Star, imageStyle: .White, forState: .Highlighted)
                    layer.borderWidth = 1
                    backgroundColor = config.starBackgroundColor
                    imageEdgeInsets.top = -1
                default:
                    if selected {
                        setImage(.Star, imageStyle: .Selected, forState: .Normal)
                    }
                    else {
                        setImage(.Star, imageStyle: .Normal, forState: .Normal)
                    }
                    setImage(.Star, imageStyle: .Selected, forState: .Highlighted)
                    layer.borderWidth = 0
                    backgroundColor = .clearColor()
                    imageEdgeInsets.top = 0
            }

            self.backgroundColor = enabled ? backgroundColor : .greyF2()
        }
    }
}
