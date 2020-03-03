////
///  StreamFooterCell.swift
//

class StreamFooterCell: CollectionViewCell {
    static let reuseIdentifier = "StreamFooterCell"

    private let toolbar = PostToolbar()

    var commentsOpened = false

    override func style() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        toolbar.clipsToBounds = true
        toolbar.isTranslucent = false
        toolbar.barTintColor = .white
        toolbar.layer.borderColor = UIColor.white.cgColor

    }

    override func bindActions() {
        toolbar.postToolsDelegate = self

        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.addTarget(self, action: #selector(longPressed(_:)))
        contentView.addGestureRecognizer(longPressGesture)
    }

    override func arrange() {
        contentView.addSubview(toolbar)

        toolbar.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }

    func updateToolbarItems(
        isGridView: Bool,
        commentVisibility: InteractionVisibility,
        loveVisibility: InteractionVisibility,
        repostVisibility: InteractionVisibility,
        shareVisibility: InteractionVisibility
    ) {
        var toolbarItems: [PostToolbar.Item] = []

        toolbar.loves.isEnabled = loveVisibility.isEnabled
        toolbar.loves.isSelected = loveVisibility.isSelected

        toolbar.reposts.isEnabled = repostVisibility.isEnabled
        toolbar.reposts.isSelected = repostVisibility.isSelected

        let desiredCount: Int
        if isGridView {
            desiredCount = 3

            if commentVisibility.isVisible {
                toolbarItems.append(.comments)
            }

            if loveVisibility.isVisible {
                toolbarItems.append(.loves)
            }

            if repostVisibility.isVisible {
                toolbarItems.append(.repost)
            }
        }
        else {
            desiredCount = 5

            toolbarItems.append(.views)

            if commentVisibility.isVisible {
                toolbarItems.append(.comments)
            }

            if loveVisibility.isVisible {
                toolbarItems.append(.loves)
            }

            if repostVisibility.isVisible {
                toolbarItems.append(.repost)
            }

            if shareVisibility.isVisible {
                toolbarItems.append(.share)
            }
        }

        while toolbarItems.count < desiredCount {
            toolbarItems.append(.space)
        }
        self.toolbar.postItems = toolbarItems
    }

    var views: PostToolbar.ImageLabelAccess { return toolbar.views }
    var comments: PostToolbar.ImageLabelAccess { return toolbar.comments }
    var loves: PostToolbar.ImageLabelAccess { return toolbar.loves }
    var reposts: PostToolbar.ImageLabelAccess { return toolbar.reposts }

    override func layoutSubviews() {
        super.layoutSubviews()
        toolbar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 44)
    }

    func cancelCommentLoading() {
        comments.isEnabled = true
        comments.isSelected = false
        commentsFinishAnimation()
        commentsOpened = false
    }

    @objc
    func longPressed(_ gesture: UIGestureRecognizer) {
        guard gesture.state == .began else { return }

        let responder: StreamEditingResponder? = findResponder()
        responder?.cellLongPressed(cell: self)
    }
}

extension StreamFooterCell: PostToolbarDelegate {
    func commentsAnimate() {
        toolbar.commentsAnimate()
    }

    func commentsFinishAnimation() {
        toolbar.commentsFinishAnimation()
    }

    @objc
    func toolbarViewsButtonTapped(viewsControl: ImageLabelControl) {
        let responder: PostbarController? = findResponder()
        responder?.viewsButtonTapped(cell: self)
    }

    @objc
    func toolbarCommentsButtonTapped(commentsControl: ImageLabelControl) {
        commentsOpened = !commentsOpened
        let responder: PostbarController? = findResponder()
        responder?.commentsButtonTapped(cell: self, imageLabelControl: commentsControl)
    }

    @objc
    func toolbarLovesButtonTapped(lovesControl: ImageLabelControl) {
        let responder: PostbarController? = findResponder()
        responder?.lovesButtonTapped(cell: self)
    }

    @objc
    func toolbarRepostButtonTapped(repostControl: ImageLabelControl) {
        let responder: PostbarController? = findResponder()
        responder?.repostButtonTapped(cell: self)
    }

    @objc
    func toolbarShareButtonTapped(shareControl: UIView) {
        let responder: PostbarController? = findResponder()
        responder?.shareButtonTapped(cell: self, sourceView: shareControl)
    }
}

extension StreamFooterCell: LoveableCell {

    func toggleLoveControl(enabled: Bool) {
        toolbar.loves.isInteractable = enabled
    }

    func toggleLoveState(loved: Bool) {
        toolbar.loves.isSelected = loved
    }

}

extension StreamFooterCell {
    class Specs {
        weak var target: StreamFooterCell!
        var toolbar: PostToolbar! { return target.toolbar }

        init(_ target: StreamFooterCell) {
            self.target = target
        }
    }

    func specs() -> Specs {
        return Specs(self)
    }
}
