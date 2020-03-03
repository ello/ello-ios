////
///  CategoryCardListView.swift
//

protocol CategoryCardListDelegate: class {
    func allCategoriesTapped()
    func editCategoriesTapped()
    func subscribedCategoryTapped()
    func categoryCardSelected(_ index: Int)
}

class CategoryCardListView: View {
    struct Size {
        static let height: CGFloat = CategoryCardView.Size.cardSize.height + 2
        static let spacing: CGFloat = 1
    }

    struct CategoryInfo {
        static let all = CategoryInfo(
            title: InterfaceString.Discover.AllCategories,
            kind: .all,
            imageURL: nil
        )
        static let subscribed = CategoryInfo(
            title: InterfaceString.Discover.Subscribed,
            kind: .subscribed,
            imageURL: nil
        )
        static let zeroState = CategoryInfo(
            title: InterfaceString.Discover.ZeroState,
            kind: .zeroState,
            imageURL: nil
        )

        enum Kind {
            case all
            case subscribed
            case zeroState
            case category
        }

        let title: String
        let kind: Kind
        let imageURL: URL?

        var isAll: Bool { return kind == .all }
        var isZeroState: Bool { return kind == .zeroState }

        init(category: Category) {
            self.init(title: category.name, kind: .category, imageURL: category.tileURL)
        }

        init(title: String, kind: Kind, imageURL: URL?) {
            self.title = title
            self.kind = kind
            self.imageURL = imageURL
        }
    }

    weak var delegate: CategoryCardListDelegate?

    var categoriesInfo: [CategoryInfo] = [] {
        didSet { updateCategoryViews() }
    }

    private var buttonIndexLookup: [UIButton: Int] = [:]
    private var categoryViews: [CategoryCardView] = []
    private let scrollView = UIScrollView()
    private var scrollViewBackground: UIView?

    var rightInset: CGFloat {
        get { return scrollView.contentInset.right }
        set {
            scrollView.contentInset.right = newValue
            scrollView.scrollIndicatorInsets.right = newValue
            setNeedsLayout()
        }
    }

    override func style() {
        backgroundColor = .white
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
    }

    override func arrange() {
        addSubview(scrollView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }

    @objc
    func allCategoriesTapped() {
        delegate?.allCategoriesTapped()
    }

    @objc
    func subscribedCategoryTapped() {
        delegate?.subscribedCategoryTapped()
    }

    @objc
    func editCategoriesTapped() {
        delegate?.editCategoriesTapped()
    }

    @objc
    func categoryButtonTapped(_ button: UIButton) {
        guard let index = buttonIndexLookup[button] else { return }
        delegate?.categoryCardSelected(index)
    }

    func scrollToIndex(_ index: Int, animated: Bool) {
        guard let view = categoryViews.safeValue(index) else { return }
        layoutIfNeeded()

        let left = view.frame.minX
        let right = view.frame.maxX - frame.width
        if scrollView.contentOffset.x > left {
            scrollView.setContentOffset(CGPoint(x: left, y: 0), animated: animated)
        }
        else if scrollView.contentOffset.x < right {
            scrollView.setContentOffset(CGPoint(x: right, y: 0), animated: animated)
        }
    }

    func selectCategory(index: Int) {
        guard let view = categoryViews.safeValue(index) else { return }

        for card in categoryViews where card != view {
            card.isSelected = false
        }

        view.isSelected = true
    }

    private func updateCategoryViews() {
        self.scrollViewBackground?.removeFromSuperview()
        for view in categoryViews {
            view.removeFromSuperview()
        }

        buttonIndexLookup = [:]

        var index = 0
        categoryViews = categoriesInfo.map { info in
            let card = CategoryCardView(info: info)

            switch info.kind {
            case .all:
                card.addTarget(self, action: #selector(allCategoriesTapped))
            case .subscribed:
                card.addTarget(self, action: #selector(subscribedCategoryTapped))
            case .zeroState:
                card.addTarget(self, action: #selector(editCategoriesTapped))
            case .category:
                buttonIndexLookup[card.button] = index
                card.addTarget(self, action: #selector(categoryButtonTapped(_:)))
                index += 1
            }

            return card
        }

        var prevView: UIView?
        for view in categoryViews {
            scrollView.addSubview(view)

            view.snp.makeConstraints { make in
                make.centerY.equalTo(scrollView)

                if let prevView = prevView {
                    make.leading.equalTo(prevView.snp.trailing).offset(Size.spacing)
                }
                else {
                    make.leading.equalTo(scrollView.snp.leading)
                }
            }

            prevView = view
        }

        if let prevView = prevView {
            let scrollViewBackground = UIView()
            scrollViewBackground.backgroundColor = .white
            scrollView.insertSubview(scrollViewBackground, at: 0)
            scrollViewBackground.snp.makeConstraints { make in
                make.leading.trailing.equalTo(scrollView)
                make.top.bottom.equalTo(prevView).inset(-Size.spacing)
            }
            self.scrollViewBackground = scrollViewBackground

            prevView.snp.makeConstraints { make in
                make.trailing.equalTo(scrollViewBackground).offset(-Size.spacing)
            }
        }
        setNeedsLayout()
    }
}
