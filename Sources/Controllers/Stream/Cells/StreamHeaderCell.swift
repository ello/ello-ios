////
///  StreamHeaderCell.swift
//

class StreamHeaderCell: UICollectionViewCell {
    static let reuseIdentifier = "StreamHeaderCell"

    var ownPost = false {
        didSet {
            self.updateItems()
        }
    }

    var ownComment = false {
        didSet {
            self.updateItems()
        }
    }

    var followButtonVisible = false {
        didSet {
            setNeedsLayout()
        }
    }

    var revealWidth: CGFloat {
        if let items = bottomToolBar.items, items.count == 4 {
            return 106.0
        }
        else {
            return 54.0
        }
    }
    var canReply = false {
        didSet {
            self.setNeedsLayout()
        }
    }

    var cellOpenObserver: NotificationObserver?
    var isOpen = false

    @IBOutlet var avatarButton: AvatarButton!
    @IBOutlet var goToPostView: UIView!
    @IBOutlet var bottomToolBar: UIToolbar!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var innerContentView: UIView!
    @IBOutlet var bottomContentView: UIView!
    @IBOutlet var categoryButton: UIButton!
    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var chevronButton: StreamFooterButton!
    @IBOutlet var usernameButton: UIButton!
    @IBOutlet var relationshipControl: RelationshipControl!
    @IBOutlet var replyButton: UIButton!
    @IBOutlet var repostedByButton: UIButton!
    @IBOutlet var repostIconView: UIImageView!

    var isGridLayout = false
    var showUsername = true {
        didSet {
            setNeedsLayout()
        }
    }

    weak var relationshipDelegate: RelationshipDelegate? {
        get { return relationshipControl.relationshipDelegate }
        set { relationshipControl.relationshipDelegate = newValue }
    }

    weak var userDelegate: UserDelegate?
    weak var categoryDelegate: CategoryDelegate?

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

    func setDetails(user: User?, repostedBy: User?, category: Category?) {
        avatarButton.setUserAvatarURL(user?.avatarURL())
        let username = user?.atName ?? ""
        usernameButton.setTitle(username, for: .normal)
        usernameButton.sizeToFit()

        relationshipControl.relationshipPriority = user?.relationshipPriority ?? .inactive
        relationshipControl.userId = user?.id ?? ""
        relationshipControl.userAtName = user?.atName ?? ""

        let repostedHidden: Bool
        if let atName = repostedBy?.atName {
            repostedByButton.setTitle("by \(atName)", for: .normal)
            repostedHidden = false
        }
        else {
            repostedByButton.setTitle("", for: .normal)
            repostedHidden = true
        }
        repostedByButton.sizeToFit()
        repostedByButton.isHidden = repostedHidden
        repostIconView.isHidden = repostedHidden

        if let category = category, repostedBy == nil {
            let attributedString = NSAttributedString(string: "in ", attributes: [
                NSFontAttributeName: UIFont.defaultFont(),
                NSForegroundColorAttributeName: UIColor.greyA(),
                ])
            let categoryName = NSAttributedString(string: category.name, attributes: [
                NSFontAttributeName: UIFont.defaultFont(),
                NSForegroundColorAttributeName: UIColor.greyA(),
                NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject,
                ])
            categoryButton.setAttributedTitle(attributedString + categoryName, for: .normal)
            categoryButton.isHidden = false
        }
        else {
            categoryButton.setTitle("", for: .normal)
            categoryButton.isHidden = true
        }
        categoryButton.sizeToFit()

        setNeedsLayout()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        bottomToolBar.isTranslucent = false
        bottomToolBar.barTintColor = UIColor.white
        bottomToolBar.clipsToBounds = true
        bottomToolBar.layer.borderColor = UIColor.white.cgColor

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        addObservers()
        addButtonHandlers()

        styleUsernameButton()
        styleTimestampLabel()

        let goToPostTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(postTapped(_:)))
        goToPostView.addGestureRecognizer(goToPostTapRecognizer)

        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.addTarget(self, action: #selector(longPressed(_:)))
        contentView.addGestureRecognizer(longPressGesture)

        replyButton.setTitle("", for: .normal)
        replyButton.setImages(.reply)

        repostIconView.image = InterfaceImage.repost.selectedImage
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        innerContentView.frame = bounds
        bottomContentView.frame = bounds
        scrollView.frame = bounds
        bottomToolBar.frame = bounds
        goToPostView.frame = bounds
        chevronButton.setImages(.angleBracket)
        scrollView.contentSize = CGSize(width: contentView.frame.size.width + revealWidth, height: scrollView.frame.size.height)
        positionTopContent()
        repositionBottomContent()
    }

// MARK: - Public

    func close() {
        isOpen = false
        closeChevron()
        scrollView.contentOffset = .zero
    }

// MARK: - Private

    fileprivate func updateItems() {
        if ownComment {
            bottomToolBar.items = [
                flexibleItem(), editItem, deleteItem, fixedItem(-10)
            ]
        }
        else if ownPost {
            bottomToolBar.items = [
                flexibleItem(), flagItem, deleteItem, fixedItem(-10)
            ]
        }
        else {
            bottomToolBar.items = [
                flexibleItem(), flagItem, fixedItem(-10)
            ]
        }
    }

    fileprivate func positionTopContent() {
        let leftSidePadding: CGFloat = 15
        let rightSidePadding: CGFloat = 15
        let avatarPadding: CGFloat = 15

        let timestampMargin: CGFloat = 11.5
        let buttonWidth: CGFloat = 30
        let buttonMargin: CGFloat = 5
        let minimumUsernameWidth: CGFloat = 44
        let minimumRepostedWidth: CGFloat = 44

        avatarButton.frame = CGRect(
            x: leftSidePadding,
            y: contentView.frame.midY - avatarHeight/2,
            width: avatarHeight,
            height: avatarHeight
            )
        let usernameX = avatarButton.frame.maxX + avatarPadding

        if chevronHidden {
            chevronButton.frame = CGRect(
                x: contentView.frame.width - rightSidePadding,
                y: 0,
                width: 0,
                height: frame.height
                )
        }
        else {
            chevronButton.frame = CGRect(
                x: contentView.frame.width - buttonWidth - buttonMargin,
                y: 0,
                width: buttonWidth,
                height: frame.height
                )
        }

        timestampLabel.sizeToFit()
        var timestampX = chevronButton.frame.x - timestampLabel.frame.width

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

        replyButton.frame.size.width = buttonWidth
        replyButton.frame.size.height = contentView.frame.size.height
        replyButton.frame.origin.x = timestampX - buttonWidth - buttonMargin - buttonMargin - rightSidePadding
        replyButton.isHidden = isGridLayout || !canReply

        var maxUsernameWidth: CGFloat = 0
        if isGridLayout {
            maxUsernameWidth = contentView.frame.width - usernameX - rightSidePadding
        }
        else {
            maxUsernameWidth = timestampX - usernameX - rightSidePadding

            if canReply {
                maxUsernameWidth -= replyButton.frame.width - timestampMargin
                timestampX -= timestampMargin
            }
        }
        let maxRepostedWidth = maxUsernameWidth - 26

        timestampLabel.frame = CGRect(
            x: timestampX,
            y: 0,
            width: timestampLabel.frame.width,
            height: contentView.frame.height
            )

        let usernameWidth = max(minimumUsernameWidth, min(usernameButton.frame.width, maxUsernameWidth))
        let repostedWidth = max(minimumRepostedWidth, min(repostedByButton.frame.width, maxRepostedWidth))
        let categoryWidth = max(minimumRepostedWidth, min(categoryButton.frame.width, maxUsernameWidth))

        let hasRepostAuthor = !repostedByButton.isHidden
        let hasCategory = !categoryButton.isHidden
        let usernameButtonHeight: CGFloat
        let usernameButtonY: CGFloat

        let secondaryLabelY: CGFloat
        if hasRepostAuthor || hasCategory {
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
    }

    fileprivate func fixedItem(_ width: CGFloat) -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        item.width = width
        return item
    }

    fileprivate func flexibleItem() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }

    fileprivate func addObservers() {
        cellOpenObserver = NotificationObserver(notification: streamCellDidOpenNotification) { cell in
            if cell != self && self.isOpen {
                nextTick {
                    animate {
                        self.close()
                    }
                }
            }
        }
    }

    fileprivate func addButtonHandlers() {
        flagControl.addTarget(self, action: #selector(StreamHeaderCell.flagButtonTapped(_:)), for: .touchUpInside)
        replyButton.addTarget(self, action: #selector(StreamHeaderCell.replyButtonTapped(_:)), for: .touchUpInside)
        deleteControl.addTarget(self, action: #selector(StreamHeaderCell.deleteButtonTapped(_:)), for: .touchUpInside)
        editControl.addTarget(self, action: #selector(StreamHeaderCell.editButtonTapped(_:)), for: .touchUpInside)
    }

    fileprivate func styleUsernameButton() {
        usernameButton.titleLabel?.font = UIFont.defaultFont()
        usernameButton.setTitleColor(UIColor.greyA(), for: .normal)
        usernameButton.titleLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
        usernameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
    }

    fileprivate func styleTimestampLabel() {
        timestampLabel.textColor = UIColor.greyA()
        timestampLabel.font = UIFont.defaultFont()
    }

    fileprivate func repositionBottomContent() {
        var frame = bottomContentView.frame
        frame.size.height = innerContentView.bounds.height
        frame.size.width = innerContentView.bounds.width
        frame.origin.y = innerContentView.frame.origin.y
        frame.origin.x = scrollView.contentOffset.x
        bottomContentView.frame = frame
    }

// MARK: - IBActions

    func postTapped(_ recognizer: UITapGestureRecognizer) {
        guard let indexPath = indexPath else { return }

        let responder = target(forAction: #selector(PostbarResponder.viewsButtonTapped(_:)), withSender: self) as? PostbarResponder
        responder?.viewsButtonTapped(indexPath)
    }

    @IBAction func userTapped(_ sender: AvatarButton) {
        userDelegate?.userTappedAuthor(cell: self)
    }

    @IBAction func usernameTapped(_ sender: UIButton) {
        userDelegate?.userTappedAuthor(cell: self)
    }

    @IBAction func categoryTapped(_ sender: UIButton) {
        categoryDelegate?.categoryCellTapped(cell: self)
    }

    @IBAction func reposterTapped(_ sender: UIButton) {
        userDelegate?.userTappedReposter(cell: self)
    }

    @IBAction func flagButtonTapped(_ sender: StreamFooterButton) {
        guard let indexPath = indexPath else { return }

        let responder = target(forAction: #selector(PostbarResponder.flagCommentButtonTapped(_:)), withSender: self) as? PostbarResponder
        responder?.flagCommentButtonTapped(indexPath)
    }

    @IBAction func replyButtonTapped(_ sender: StreamFooterButton) {
        guard let indexPath = indexPath else { return }

        let responder = target(forAction: #selector(PostbarResponder.replyToCommentButtonTapped(_:)), withSender: self) as? PostbarResponder
        responder?.replyToCommentButtonTapped(indexPath)
    }

    @IBAction func deleteButtonTapped(_ sender: StreamFooterButton) {
        guard let indexPath = indexPath else { return }

        let responder = target(forAction: #selector(PostbarResponder.deleteCommentButtonTapped(_:)), withSender: self) as? PostbarResponder
        responder?.deleteCommentButtonTapped(indexPath)
    }

    @IBAction func editButtonTapped(_ sender: StreamFooterButton) {
        guard let indexPath = indexPath else { return }

        let responder = target(forAction: #selector(PostbarResponder.editCommentButtonTapped(_:)), withSender: self) as? PostbarResponder
        responder?.editCommentButtonTapped(indexPath)
    }

    @IBAction func chevronButtonTapped(_ sender: StreamFooterButton) {
        let contentOffset = isOpen ? .zero : CGPoint(x: revealWidth, y: 0)
        animate {
            self.scrollView.contentOffset = contentOffset
            self.openChevron(isOpen: self.isOpen)
        }
        Tracker.shared.commentBarVisibilityChanged(isOpen)
    }

    @IBAction func longPressed(_ gesture: UIGestureRecognizer) {
        guard gesture.state == .began else { return }

        let responder = target(forAction: #selector(StreamEditingResponder.cellLongPressed(cell:)), withSender: self) as? StreamEditingResponder
        responder?.cellLongPressed(cell: self)
    }
}

extension StreamHeaderCell {

    fileprivate func openChevron(isOpen: Bool) {
        if isOpen {
            rotateChevron(CGFloat(0))
        }
        else {
            rotateChevron(CGFloat(M_PI))
        }
    }

    fileprivate func closeChevron() {
        openChevron(isOpen: false)
    }

    fileprivate func rotateChevron(_ angle: CGFloat) {
        var normalized = angle
        if angle < CGFloat(-M_PI) {
            normalized = CGFloat(-M_PI)
        }
        else if angle > CGFloat(M_PI) {
            normalized = CGFloat(M_PI)
        }
        self.chevronButton.transform = CGAffineTransform(rotationAngle: normalized)
    }

}

extension StreamHeaderCell: ElloTextViewDelegate {
    func textViewTapped(_ link: String, object: ElloAttributedObject) {
        userDelegate?.userTappedAuthor(cell: self)
    }
    func textViewTappedDefault() {}
}

// MARK: UIScrollViewDelegate
extension StreamHeaderCell: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        repositionBottomContent()

        if scrollView.contentOffset.x < 0 {
            scrollView.contentOffset = .zero
        }

        if scrollView.contentOffset.x >= revealWidth {
            if !isOpen {
                isOpen = true
                openChevron(isOpen: true)
                postNotification(streamCellDidOpenNotification, value: self)
                Tracker.shared.commentBarVisibilityChanged(true)
            }
        } else {
            let angle: CGFloat = -CGFloat(M_PI) + CGFloat(M_PI) * scrollView.contentOffset.x / revealWidth
            rotateChevron(angle)
            isOpen = false
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.x > 0 {
            targetContentOffset.pointee.x = revealWidth
        }
        else {
            targetContentOffset.pointee.x = 0
        }
    }

}
