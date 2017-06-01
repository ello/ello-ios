////
///  StreamFooterCell.swift
//

let streamCellDidOpenNotification = TypedNotification<UICollectionViewCell>(name: "StreamCellDidOpenNotification")

class StreamFooterCell: UICollectionViewCell {
    static let reuseIdentifier = "StreamFooterCell"

    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var innerContentView: UIView!

    var commentsOpened = false

    let viewsItem = ElloPostToolBarOption.views.barButtonItem()
    var viewsControl: ImageLabelControl {
        return self.viewsItem.customView as! ImageLabelControl
    }

    let lovesItem = ElloPostToolBarOption.loves.barButtonItem()
    var lovesControl: ImageLabelControl {
        return self.lovesItem.customView as! ImageLabelControl
    }

    let commentsItem = ElloPostToolBarOption.comments.barButtonItem()
    var commentsControl: ImageLabelControl {
        return self.commentsItem.customView as! ImageLabelControl
    }

    let repostItem = ElloPostToolBarOption.repost.barButtonItem()
    var repostControl: ImageLabelControl {
        return self.repostItem.customView as! ImageLabelControl
    }

    let shareItem = ElloPostToolBarOption.share.barButtonItem()
    var shareControl: ImageLabelControl {
        return self.shareItem.customView as! ImageLabelControl
    }

    let replyItem = ElloPostToolBarOption.reply.barButtonItem()
    var replyControl: ImageLabelControl {
        return self.replyItem.customView as! ImageLabelControl
    }

    fileprivate func updateButtonVisibility(_ button: UIControl, visibility: InteractionVisibility) {
        button.isHidden = !visibility.isVisible
        button.isEnabled = visibility.isEnabled
        button.isSelected = visibility.isSelected
    }

    func updateToolbarItems(
        isGridView: Bool,
        repostVisibility: InteractionVisibility,
        commentVisibility: InteractionVisibility,
        shareVisibility: InteractionVisibility,
        loveVisibility: InteractionVisibility
        )
    {
        updateButtonVisibility(self.repostControl, visibility: repostVisibility)
        updateButtonVisibility(self.lovesControl, visibility: loveVisibility)
        var toolbarItems: [UIBarButtonItem] = []

        let desiredCount: Int
        if isGridView {
            desiredCount = 3

            if commentVisibility.isVisible {
                toolbarItems.append(commentsItem)
            }

            if loveVisibility.isVisible {
                toolbarItems.append(lovesItem)
            }

            if repostVisibility.isVisible {
                toolbarItems.append(repostItem)
            }
        }
        else {
            desiredCount = 5

            toolbarItems.append(viewsItem)

            if commentVisibility.isVisible {
                toolbarItems.append(commentsItem)
            }

            if loveVisibility.isVisible {
                toolbarItems.append(lovesItem)
            }

            if repostVisibility.isVisible {
                toolbarItems.append(repostItem)
            }

            if shareVisibility.isVisible {
                toolbarItems.append(shareItem)
            }
        }

        while toolbarItems.count < desiredCount {
            toolbarItems.append(fixedItem(44))
        }
        self.toolBar.items = Array(toolbarItems.flatMap { [self.flexibleItem(), $0] }.dropFirst())
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        toolBar.isTranslucent = false
        toolBar.barTintColor = UIColor.white
        toolBar.clipsToBounds = true
        toolBar.layer.borderColor = UIColor.white.cgColor

        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.addTarget(self, action: #selector(longPressed(_:)))
        contentView.addGestureRecognizer(longPressGesture)

        addButtonHandlers()
    }

    var views: String? {
        get { return viewsControl.title }
        set { viewsControl.title = newValue }
    }

    var comments: String? {
        get { return commentsControl.title }
        set { commentsControl.title = newValue }
    }

    var loves: String? {
        get { return lovesControl.title }
        set { lovesControl.title = newValue }
    }

    var reposts: String? {
        get { return repostControl.title }
        set { repostControl.title = newValue }
    }

// MARK: - Private

    fileprivate func fixedItem(_ width: CGFloat) -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        item.width = width
        return item
    }

    fileprivate func flexibleItem() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }

    fileprivate func addButtonHandlers() {
        commentsControl.addTarget(self, action: #selector(StreamFooterCell.commentsButtonTapped), for: .touchUpInside)
        lovesControl.addTarget(self, action: #selector(StreamFooterCell.lovesButtonTapped), for: .touchUpInside)
        replyControl.addTarget(self, action: #selector(StreamFooterCell.replyButtonTapped), for: .touchUpInside)
        repostControl.addTarget(self, action: #selector(StreamFooterCell.repostButtonTapped), for: .touchUpInside)
        shareControl.addTarget(self, action: #selector(StreamFooterCell.shareButtonTapped), for: .touchUpInside)
        viewsControl.addTarget(self, action: #selector(StreamFooterCell.viewsButtonTapped), for: .touchUpInside)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let newBounds = CGRect(x: 0, y: 0, width: bounds.width, height: 44)
        contentView.frame = newBounds
        innerContentView.frame = newBounds
        containerView.frame = newBounds
        toolBar.frame = newBounds
    }

// MARK: - IBActions

    @IBAction func viewsButtonTapped() {
        let responder: PostbarResponder? = findResponder()
        responder?.viewsButtonTapped(self)
    }

    @IBAction func commentsButtonTapped() {
        commentsOpened = !commentsOpened
        let responder: PostbarResponder? = findResponder()
        responder?.commentsButtonTapped(self, imageLabelControl: commentsControl)
    }

    func cancelCommentLoading() {
        commentsControl.isEnabled = true
        commentsControl.finishAnimation()
        commentsControl.isSelected = false
        commentsOpened = false
    }

    @IBAction func lovesButtonTapped() {
        let responder: PostbarResponder? = findResponder()
        responder?.lovesButtonTapped(self)
    }

    @IBAction func repostButtonTapped() {
        let responder: PostbarResponder? = findResponder()
        responder?.repostButtonTapped(self)
    }

    @IBAction func shareButtonTapped() {
        let responder: PostbarResponder? = findResponder()
        responder?.shareButtonTapped(self, sourceView: shareControl)
    }

    @IBAction func replyButtonTapped() {
    }

    @IBAction func longPressed(_ gesture: UIGestureRecognizer) {
        guard gesture.state == .began else { return }

        let responder: StreamEditingResponder? = findResponder()
        responder?.cellLongPressed(cell: self)
    }
}

extension StreamFooterCell: LoveableCell {

    func toggleLoveControl(enabled: Bool) {
        lovesControl.isUserInteractionEnabled = enabled
    }

    func toggleLoveState(loved: Bool) {
    }

}
