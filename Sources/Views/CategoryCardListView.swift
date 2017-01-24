////
///  CategoryCardListView.swift
//

protocol CategoryCardListDelegate: class {
    func categoryCardSelected(_ index: Int)
}

class CategoryCardListView: UIView {
    weak var delegate: CategoryCardListDelegate?

    struct CategoryInfo {
        let title: String
        let imageURL: URL?
    }

    struct Size {
        static let height: CGFloat = 70
        static let cardSize: CGSize = CGSize(width: 100, height: 68)
        static let spacing: CGFloat = 1
    }

    var categoriesInfo: [CategoryInfo] = [] {
        didSet {
            let changed: Bool = (categoriesInfo.count != oldValue.count) || oldValue.enumerated().any { (index, info) in
                return info.title != categoriesInfo[index].title
            }
            if changed {
                updateCategoryViews()
            }
        }
    }

    fileprivate var buttonIndexLookup: [UIButton: Int] = [:]
    fileprivate var categoryViews: [CategoryCardView] = []
    fileprivate var scrollView = UIScrollView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        style()
        bindActions()
        arrange()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func style() {
        backgroundColor = .white
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
    }

    fileprivate func bindActions() {
    }

    fileprivate func arrange() {
        self.addSubview(scrollView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }

    @objc
    func categoryButtonTapped(_ button: UIButton) {
        guard let index = buttonIndexLookup[button] else { return }
        delegate?.categoryCardSelected(index)
    }

    func scrollToIndex(_ index: Int, animated: Bool) {
        guard let view = categoryViews.safeValue(index) else { return }

        let x = max(min(view.frame.minX, scrollView.contentSize.width - frame.width), 0)
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: animated)
    }

    func selectCategoryIndex(_ index: Int) {
        guard let view = categoryViews.safeValue(index) else { return }
        for card in categoryViews {
            card.selected = false
        }

        view.selected = true
    }

    fileprivate func updateCategoryViews() {
        for view in categoryViews {
            view.removeFromSuperview()
        }

        buttonIndexLookup = [:]

        categoryViews = categoriesInfo.enumerated().map { (index, info) in
            return categoryView(index: index, info: info)
        }
        arrangeCategoryViews()

        layoutIfNeeded()
    }

    fileprivate func categoryView(index: Int, info: CategoryInfo) -> CategoryCardView {
        let card = CategoryCardView(frame: .zero, info: info)
        card.button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
        buttonIndexLookup[card.button] = index
        return card
    }

    fileprivate func arrangeCategoryViews() {
        var prevView: UIView? = nil
        for view in categoryViews {
            scrollView.addSubview(view)

            view.snp.makeConstraints { make in
                make.size.equalTo(Size.cardSize)
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
            prevView.snp.makeConstraints { make in
                make.trailing.equalTo(scrollView.snp.trailing)
            }
        }
    }
}
