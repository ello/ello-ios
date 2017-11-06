////
///  StreamHeaderCell.swift
//

let streamHeaderCellDidOpenNotification = TypedNotification<UICollectionViewCell>(name: "StreamCellDidOpenNotification")


class StreamHeaderCell: UICollectionViewCell {
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

    @IBOutlet var avatarButton: AvatarButton!
    @IBOutlet var categoryButton: UIButton!
    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var usernameButton: UIButton!
    @IBOutlet var relationshipControl: RelationshipControl!
    @IBOutlet var repostedByButton: UIButton!
    @IBOutlet var repostIconView: UIImageView!
    @IBOutlet var artistInviteSubmissionButton: UIButton!

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

    let flagItem = ElloPostToolBarOption.flag.barButtonItem()
    var flagControl: ImageLabelControl {
        return self.flagItem.customView as! ImageLabelControl
    }

    let editItem = ElloPostToolBarOption.edit.barButtonItem()
    var editControl: ImageLabelControl {
       return self.editItem.customView as! ImageLabelControl
    }

    let deleteItem = ElloPostToolBarOption.delete.barButtonItem()
    var deleteControl: ImageLabelControl {
        return self.deleteItem.customView as! ImageLabelControl
    }

    func setDetails(user: User?, repostedBy: User?, category: Category?, isSubmission: Bool) {
        avatarButton.setUserAvatarURL(user?.avatarURL())
        let username = user?.atName ?? ""
        usernameButton.setTitle(username, for: .normal)
        usernameButton.sizeToFit()

        relationshipControl.relationshipPriority = user?.relationshipPriority ?? .inactive
        relationshipControl.userId = user?.id ?? ""
        relationshipControl.userAtName = user?.atName ?? ""

        let repostedVisible: Bool
        let aiSubmissionVisible: Bool
        if let atName = repostedBy?.atName {
            repostedByButton.setTitle("by \(atName)", for: .normal)
            repostedByButton.sizeToFit()

            repostedVisible = true
            aiSubmissionVisible = false
        }
        else {
            repostedVisible = false
            aiSubmissionVisible = isSubmission
        }
        let categoryVisible: Bool = category != nil && !repostedVisible && !aiSubmissionVisible
        repostedByButton.isHidden = !repostedVisible
        repostIconView.isHidden = !repostedVisible
        categoryButton.isHidden = !categoryVisible
        artistInviteSubmissionButton.isHidden = !aiSubmissionVisible

        if let category = category, categoryVisible {
            let attributedString = NSAttributedString(string: "in ", attributes: [
                .font: UIFont.defaultFont(),
                .foregroundColor: UIColor.greyA,
                ])
            let categoryName = NSAttributedString(string: category.name, attributes: [
                .font: UIFont.defaultFont(),
                .foregroundColor: UIColor.greyA,
                .underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
                ])
            categoryButton.setAttributedTitle(attributedString + categoryName, for: .normal)
            categoryButton.sizeToFit()
        }

        setNeedsLayout()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        styleUsernameButton()
        styleTimestampLabel()

        let goToPostTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(postTapped(_:)))
        contentView.addGestureRecognizer(goToPostTapRecognizer)

        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.addTarget(self, action: #selector(longPressed(_:)))
        contentView.addGestureRecognizer(longPressGesture)

        repostIconView.setInterfaceImage(.repost, style: .selected)

        let attributedSubmissionTitle = NSAttributedString(string: InterfaceString.ArtistInvites.PostSubmissionHeader, attributes: [
            .font: UIFont.defaultFont(),
            .foregroundColor: UIColor.greyA,
            .underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
            ])
        artistInviteSubmissionButton.setAttributedTitle(attributedSubmissionTitle, for: .normal)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        positionTopContent()
    }

    private func positionTopContent() {
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

        relationshipControl.isHidden = !followButtonVisible
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

    private func styleUsernameButton() {
        usernameButton.titleLabel?.font = UIFont.defaultFont()
        usernameButton.setTitleColor(UIColor.greyA, for: .normal)
        usernameButton.titleLabel?.lineBreakMode = .byTruncatingTail
        usernameButton.contentHorizontalAlignment = .left
    }

    private func styleTimestampLabel() {
        timestampLabel.textColor = UIColor.greyA
        timestampLabel.font = UIFont.defaultFont()
    }

// MARK: - IBActions

    @objc
    func postTapped(_ recognizer: UITapGestureRecognizer) {
        let responder: PostbarResponder? = findResponder()
        responder?.viewsButtonTapped(self)
    }

    @IBAction func userTapped(_ sender: AvatarButton) {
        let responder: UserResponder? = findResponder()
        responder?.userTappedAuthor(cell: self)
    }

    @IBAction func categoryTapped(_ sender: UIButton) {
        let responder: CategoryResponder? = findResponder()
        responder?.categoryCellTapped(cell: self)
    }

    @IBAction func artistInviteSubmissionTapped(_ sender: UIButton) {
        let responder: StreamCellResponder? = findResponder()
        responder?.artistInviteSubmissionTapped(cell: self)
    }

    @IBAction func reposterTapped(_ sender: UIButton) {
        let responder: UserResponder? = findResponder()
        responder?.userTappedReposter(cell: self)
    }

    @IBAction func longPressed(_ gesture: UIGestureRecognizer) {
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
