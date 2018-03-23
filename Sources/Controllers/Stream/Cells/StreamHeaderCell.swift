////
///  StreamHeaderCell.swift
//

let streamHeaderCellDidOpenNotification = TypedNotification<UICollectionViewCell>(name: "StreamCellDidOpenNotification")


class StreamHeaderCell: CollectionViewCell {
    static let reuseIdentifier = "StreamHeaderCell"
    struct Size {
        static let height: CGFloat = 70
        static let gridAvatarHeight: CGFloat = 30
        static let listAvatarHeight: CGFloat = 40
    }

    static func avatarHeight(isGridView: Bool) -> CGFloat {
        return isGridView ? Size.gridAvatarHeight : Size.listAvatarHeight
    }

    var followButtonVisible = false {
        didSet {
            setNeedsLayout()
        }
    }

    private let avatarButton = AvatarButton()
    private let timestampLabel = StyledLabel(style: .gray)
    private let usernameButton = StyledButton(style: .clearGray)
    private let relationshipControl = RelationshipControl()
    private let repostIconView = UIImageView()
    private let repostedByButton = StyledButton(style: .clearGray)
    private let categoryButton = StyledButton(style: .clearGray)
    private let artistInviteSubmissionButton = StyledButton(style: .clearGray)

    var isGridLayout = false
    var showUsername = true {
        didSet {
            setNeedsLayout()
        }
    }

    var avatarHeight: CGFloat = 60.0 {
        didSet { setNeedsDisplay() }
    }

    var timeStamp: String {
        get { return self.timestampLabel.text ?? "" }
        set {
            if isGridLayout {
                timestampLabel.text = ""
            }
            else {
                timestampLabel.text = newValue
            }
            setNeedsLayout()
        }
    }

    var chevronHidden = false

    let flagItem = ElloPostToolBarOption.flag.barButtonItem(isDark: false)
    var flagControl: ImageLabelControl {
        return self.flagItem.customView as! ImageLabelControl
    }

    let editItem = ElloPostToolBarOption.edit.barButtonItem(isDark: false)
    var editControl: ImageLabelControl {
       return self.editItem.customView as! ImageLabelControl
    }

    let deleteItem = ElloPostToolBarOption.delete.barButtonItem(isDark: false)
    var deleteControl: ImageLabelControl {
        return self.deleteItem.customView as! ImageLabelControl
    }

    override func bindActions() {
        avatarButton.addTarget(self, action: #selector(userTapped), for: .touchUpInside)
        usernameButton.addTarget(self, action: #selector(userTapped), for: .touchUpInside)
        repostedByButton.addTarget(self, action: #selector(reposterTapped), for: .touchUpInside)
        categoryButton.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)
        artistInviteSubmissionButton.addTarget(self, action: #selector(artistInviteSubmissionTapped), for: .touchUpInside)
    }

    override func style() {
        contentView.backgroundColor = .white

        categoryButton.titleLineBreakMode = .byTruncatingTail
        repostedByButton.titleLineBreakMode = .byTruncatingTail
        usernameButton.titleLineBreakMode = .byTruncatingTail
        usernameButton.contentHorizontalAlignment = .left

        let goToPostTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(postTapped(_:)))
        contentView.addGestureRecognizer(goToPostTapRecognizer)

        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.addTarget(self, action: #selector(longPressed(_:)))
        contentView.addGestureRecognizer(longPressGesture)

        repostIconView.setInterfaceImage(.repost, style: .selected)

        let attributedSubmissionTitle = NSAttributedString(button: InterfaceString.ArtistInvites.PostSubmissionHeader, style: .grayUnderlined)
        artistInviteSubmissionButton.setAttributedTitle(attributedSubmissionTitle, for: .normal)
    }

    override func arrange() {
        super.arrange()

        contentView.addSubview(avatarButton)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(usernameButton)
        contentView.addSubview(relationshipControl)
        contentView.addSubview(repostIconView)
        contentView.addSubview(repostedByButton)
        contentView.addSubview(categoryButton)
        contentView.addSubview(artistInviteSubmissionButton)

        repostIconView.frame.size = CGSize(width: 20, height: 20)
    }

    func setDetails(user: User?, repostedBy: User?, category: Category?, isSubmission: Bool) {
        avatarButton.setUserAvatarURL(user?.avatarURL())
        let username = user?.atName ?? ""
        usernameButton.title = username
        usernameButton.sizeToFit()

        relationshipControl.relationshipPriority = user?.relationshipPriority ?? .inactive
        relationshipControl.userId = user?.id ?? ""
        relationshipControl.userAtName = user?.atName ?? ""

        let repostedVisible: Bool
        let aiSubmissionVisible: Bool
        if let atName = repostedBy?.atName {
            repostedByButton.title = "by \(atName)"
            repostedByButton.sizeToFit()

            repostedVisible = true
            aiSubmissionVisible = false
        }
        else {
            repostedVisible = false
            aiSubmissionVisible = isSubmission
        }
        let categoryVisible: Bool = category != nil && !repostedVisible && !aiSubmissionVisible
        repostedByButton.isVisible = repostedVisible
        repostIconView.isVisible = repostedVisible
        categoryButton.isVisible = categoryVisible
        artistInviteSubmissionButton.isVisible = aiSubmissionVisible

        if let category = category, categoryVisible {
            let attributedString = NSAttributedString(label: "in ", style: .gray, lineBreakMode: .byTruncatingTail)
            let categoryName = NSAttributedString(button: category.name, style: .grayUnderlined, lineBreakMode: .byTruncatingTail)
            categoryButton.setAttributedTitle(attributedString + categoryName, for: .normal)
            categoryButton.titleLineBreakMode = .byTruncatingTail
            categoryButton.sizeToFit()
        }

        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let leftSidePadding: CGFloat = 15
        let rightSidePadding: CGFloat = 15
        let avatarPadding: CGFloat = 15

        let minimumUsernameWidth: CGFloat = 44
        let minimumRepostedWidth: CGFloat = 44

        avatarButton.frame = CGRect(
            x: leftSidePadding,
            y: contentView.frame.midY - avatarHeight/2,
            width: avatarHeight,
            height: avatarHeight
            )
        let usernameX = avatarButton.frame.maxX + avatarPadding

        timestampLabel.sizeToFit()

        relationshipControl.isVisible = followButtonVisible
        usernameButton.isHidden = followButtonVisible
        if followButtonVisible {
            let relationshipControlSize = relationshipControl.intrinsicContentSize
            relationshipControl.frame.size = relationshipControlSize
            relationshipControl.frame.origin.y = (contentView.frame.height - relationshipControlSize.height) / 2

            if showUsername {
                let relationshipControlPadding: CGFloat = 7
                relationshipControl.frame.origin.x = contentView.frame.width - relationshipControlPadding - relationshipControlSize.width
            }
            else {
                let relationshipControlPadding: CGFloat = 15
                relationshipControl.frame.origin.x = avatarButton.frame.maxX + relationshipControlPadding
            }
        }

        let timestampX = contentView.frame.width - rightSidePadding - timestampLabel.frame.width
        timestampLabel.frame = CGRect(
            x: timestampX,
            y: 0,
            width: timestampLabel.frame.width,
            height: contentView.frame.height
            )

        var maxUsernameWidth: CGFloat = 0
        if isGridLayout {
            maxUsernameWidth = contentView.frame.width - usernameX - rightSidePadding
        }
        else {
            maxUsernameWidth = timestampX - usernameX - rightSidePadding
        }
        let maxRepostedWidth = maxUsernameWidth - 26

        let usernameWidth = max(minimumUsernameWidth, min(usernameButton.frame.width, maxUsernameWidth))
        let repostedWidth = max(minimumRepostedWidth, min(repostedByButton.frame.width, maxRepostedWidth))
        let categoryWidth = max(minimumRepostedWidth, min(categoryButton.frame.width, maxUsernameWidth))

        let hasRepostAuthor = !repostedByButton.isHidden
        let hasCategory = !categoryButton.isHidden
        let hasAISubmission = !artistInviteSubmissionButton.isHidden
        let usernameButtonHeight: CGFloat
        let usernameButtonY: CGFloat

        let secondaryLabelY: CGFloat
        if hasRepostAuthor || hasCategory || hasAISubmission {
            usernameButtonHeight = 20
            usernameButtonY = contentView.frame.height / 2 - usernameButtonHeight

            if followButtonVisible {
                let relationshipControlCorrection: CGFloat = 2
                let repostLabelCorrection: CGFloat = 2
                relationshipControl.frame.origin.y -= usernameButtonHeight / 2 - relationshipControlCorrection
                secondaryLabelY = relationshipControl.frame.maxY + repostLabelCorrection
            }
            else {
                secondaryLabelY = contentView.frame.height / 2
            }
        }
        else {
            usernameButtonHeight = contentView.frame.height
            usernameButtonY = 0
            secondaryLabelY = 0
        }

        usernameButton.frame = CGRect(
            x: usernameX,
            y: usernameButtonY,
            width: usernameWidth,
            height: usernameButtonHeight
        )
        let repostIconY = secondaryLabelY + (usernameButtonHeight - repostIconView.frame.height) / 2
        repostIconView.frame.origin = CGPoint(
            x: usernameX,
            y: repostIconY
        )
        repostedByButton.frame = CGRect(
            x: repostIconView.frame.maxX + 6,
            y: secondaryLabelY,
            width: repostedWidth,
            height: usernameButtonHeight
        )
        categoryButton.frame = CGRect(
            x: usernameX,
            y: secondaryLabelY,
            width: categoryWidth,
            height: usernameButtonHeight
        )
        artistInviteSubmissionButton.frame.origin = CGPoint(
            x: usernameX,
            y: secondaryLabelY
            )
        artistInviteSubmissionButton.frame.size.height = usernameButtonHeight
    }

    private func fixedItem(_ width: CGFloat) -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        item.width = width
        return item
    }

    private func flexibleItem() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }

    @objc
    func postTapped(_ recognizer: UITapGestureRecognizer) {
        let responder: PostbarController? = findResponder()
        responder?.viewsButtonTapped(cell: self)
    }

    @objc
    func userTapped() {
        let responder: UserResponder? = findResponder()
        responder?.userTappedAuthor(cell: self)
    }

    @objc
    func categoryTapped() {
        let responder: CategoryResponder? = findResponder()
        responder?.categoryCellTapped(cell: self)
    }

    @objc
    func artistInviteSubmissionTapped() {
        let responder: StreamCellResponder? = findResponder()
        responder?.artistInviteSubmissionTapped(cell: self)
    }

    @objc
    func reposterTapped() {
        let responder: UserResponder? = findResponder()
        responder?.userTappedReposter(cell: self)
    }

    @objc
    func longPressed(_ gesture: UIGestureRecognizer) {
        guard gesture.state == .began else { return }

        let responder: StreamEditingResponder? = findResponder()
        responder?.cellLongPressed(cell: self)
    }
}

extension StreamHeaderCell: ElloTextViewDelegate {
    func textViewTapped(_ link: String, object: ElloAttributedObject) {
        let responder: UserResponder? = findResponder()
        responder?.userTappedAuthor(cell: self)
    }
    func textViewTappedDefault() {}
}

extension StreamHeaderCell {
    class Specs {
        weak var target: StreamHeaderCell!
        var avatarButton: AvatarButton! { return target.avatarButton }
        var timestampLabel: StyledLabel! { return target.timestampLabel }
        var usernameButton: StyledButton! { return target.usernameButton }
        var relationshipControl: RelationshipControl! { return target.relationshipControl }
        var repostIconView: UIImageView! { return target.repostIconView }
        var repostedByButton: StyledButton! { return target.repostedByButton }
        var categoryButton: StyledButton! { return target.categoryButton }
        var artistInviteSubmissionButton: StyledButton! { return target.artistInviteSubmissionButton }

        init(_ target: StreamHeaderCell) {
            self.target = target
        }
    }

    func specs() -> Specs {
        return Specs(self)
    }
}
