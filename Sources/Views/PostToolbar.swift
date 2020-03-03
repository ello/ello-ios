////
///  PostToolbar.swift
//

class PostToolbar: UIToolbar {
    enum Style {
        case white
        case dark
    }

    enum Item {
        case views
        case loves
        case comments
        case repost
        case share
        case space
    }

    var style: Style = .white { didSet { updateStyle() } }
    var postItems: [Item] = [] { didSet { updateItems() } }
    weak var postToolsDelegate: PostToolbarDelegate?

    class ImageLabelAccess {
        let control: ImageLabelControl

        init(control: ImageLabelControl) {
            self.control = control
        }

        var title: String? {
            get { return control.title }
            set { control.title = newValue }
        }
        var isEnabled: Bool {
            get { return control.isEnabled }
            set { control.isEnabled = newValue }
        }
        var isSelected: Bool {
            get { return control.isSelected }
            set { control.isSelected = newValue }
        }
        var isInteractable: Bool {
            get { return control.isUserInteractionEnabled }
            set { control.isUserInteractionEnabled = newValue }
        }
    }

    private var viewsItem: UIBarButtonItem!
    private var viewsControl: ImageLabelControl {
        return self.viewsItem.customView as! ImageLabelControl
    }

    private var lovesItem: UIBarButtonItem!
    private var lovesControl: ImageLabelControl {
        return self.lovesItem.customView as! ImageLabelControl
    }

    private var commentsItem: UIBarButtonItem!
    private var commentsControl: ImageLabelControl {
        return self.commentsItem.customView as! ImageLabelControl
    }

    private var repostItem: UIBarButtonItem!
    private var repostControl: ImageLabelControl {
        return self.repostItem.customView as! ImageLabelControl
    }

    private var shareItem: UIBarButtonItem!
    private var shareControl: UIControl {
        return self.shareItem.customView as! UIControl
    }

    var views: ImageLabelAccess { return ImageLabelAccess(control: viewsControl) }
    var comments: ImageLabelAccess { return ImageLabelAccess(control: commentsControl) }
    var loves: ImageLabelAccess { return ImageLabelAccess(control: lovesControl) }
    var reposts: ImageLabelAccess { return ImageLabelAccess(control: repostControl) }

    required override init(frame: CGRect) {
        super.init(frame: frame)
        updateStyle()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateStyle()
    }

    convenience init() {
        self.init(frame: .zero)
    }

    private func updateStyle() {
        let selectedColor: UIColor
        let isDark: Bool

        switch style {
        case .white:
            backgroundColor = .white
            setBackgroundImage(nil, forToolbarPosition: .any, barMetrics: .default)
            setShadowImage(nil, forToolbarPosition: .any)
            selectedColor = .black
            isDark = false
        case .dark:
            backgroundColor = .clear
            setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
            setShadowImage(UIImage(), forToolbarPosition: .any)
            selectedColor = .white
            isDark = true
        }

        let oldViewsControl = viewsItem?.customView as? ImageLabelControl
        viewsItem = ElloPostToolBarOption.views.barButtonItem(isDark: isDark)
        viewsControl.addTarget(self, action: #selector(viewsButtonTapped), for: .touchUpInside)
        if let oldViewsControl = oldViewsControl {
            viewsControl.isEnabled = oldViewsControl.isEnabled
            viewsControl.isSelected = oldViewsControl.isSelected
            viewsControl.isUserInteractionEnabled = oldViewsControl.isUserInteractionEnabled
        }

        let oldLovesControl = lovesItem?.customView as? ImageLabelControl
        lovesItem = ElloPostToolBarOption.loves.barButtonItem(isDark: isDark)
        lovesControl.addTarget(self, action: #selector(lovesButtonTapped), for: .touchUpInside)
        if let oldLovesControl = oldLovesControl {
            lovesControl.isEnabled = oldLovesControl.isEnabled
            lovesControl.isSelected = oldLovesControl.isSelected
            lovesControl.isUserInteractionEnabled = oldLovesControl.isUserInteractionEnabled
        }

        let oldCommentsControl = commentsItem?.customView as? ImageLabelControl
        commentsItem = ElloPostToolBarOption.comments.barButtonItem(isDark: isDark)
        commentsControl.addTarget(
            self,
            action: #selector(commentsButtonTapped),
            for: .touchUpInside
        )
        if let oldCommentsControl = oldCommentsControl {
            commentsControl.isEnabled = oldCommentsControl.isEnabled
            commentsControl.isSelected = oldCommentsControl.isSelected
            commentsControl.isUserInteractionEnabled = oldCommentsControl.isUserInteractionEnabled
        }

        let oldRepostControl = repostItem?.customView as? ImageLabelControl
        repostItem = ElloPostToolBarOption.repost.barButtonItem(isDark: isDark)
        repostControl.addTarget(self, action: #selector(repostButtonTapped), for: .touchUpInside)
        if let oldRepostControl = oldRepostControl {
            repostControl.isEnabled = oldRepostControl.isEnabled
            repostControl.isSelected = oldRepostControl.isSelected
            repostControl.isUserInteractionEnabled = oldRepostControl.isUserInteractionEnabled
        }

        let oldShareControl = shareItem?.customView as? UIControl
        let control = UIButton()
        control.setImage(.share, imageStyle: .normal, for: .normal)
        control.setImage(.share, imageStyle: isDark ? .white : .selected, for: .selected)
        shareItem = UIBarButtonItem(customView: control)
        shareControl.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        if let oldShareControl = oldShareControl {
            shareControl.isEnabled = oldShareControl.isEnabled
            shareControl.isSelected = oldShareControl.isSelected
            shareControl.isUserInteractionEnabled = oldShareControl.isUserInteractionEnabled
        }

        let controls = [viewsControl, lovesControl, commentsControl, repostControl]
        for control in controls {
            control.selectedColor = selectedColor
        }

        updateItems()
    }

    private func updateItems() {
        self.items = Array(
            postItems.map { item in
                switch item {
                case .views: return viewsItem
                case .loves: return lovesItem
                case .comments: return commentsItem
                case .repost: return repostItem
                case .share: return shareItem
                case .space: return fixedItem()
                }
            }.flatMap { [flexibleItem(), $0] }.dropFirst()
        )
    }

    private func fixedItem() -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        item.width = 44
        return item
    }

    private func flexibleItem() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
}

extension PostToolbar {
    func commentsAnimate() {
        commentsControl.animate()
    }

    func commentsFinishAnimation() {
        commentsControl.finishAnimation()
    }

    @objc
    func viewsButtonTapped() {
        postToolsDelegate?.toolbarViewsButtonTapped(viewsControl: viewsControl)
    }

    @objc
    func commentsButtonTapped() {
        postToolsDelegate?.toolbarCommentsButtonTapped(commentsControl: commentsControl)
    }

    @objc
    func lovesButtonTapped() {
        postToolsDelegate?.toolbarLovesButtonTapped(lovesControl: lovesControl)
    }

    @objc
    func repostButtonTapped() {
        postToolsDelegate?.toolbarRepostButtonTapped(repostControl: repostControl)
    }

    @objc
    func shareButtonTapped() {
        postToolsDelegate?.toolbarShareButtonTapped(shareControl: shareControl)
    }
}

protocol PostToolbarDelegate: class {
    func toolbarViewsButtonTapped(viewsControl: ImageLabelControl)
    func toolbarCommentsButtonTapped(commentsControl: ImageLabelControl)
    func toolbarLovesButtonTapped(lovesControl: ImageLabelControl)
    func toolbarRepostButtonTapped(repostControl: ImageLabelControl)
    func toolbarShareButtonTapped(shareControl: UIView)
}
