////
///  CategoryListCell.swift
//

import SnapKit

class CategoryListCell: UICollectionViewCell {
    static let reuseIdentifier = "CategoryListCell"

    struct Size {
        static let height: CGFloat = 45
        static let spacing: CGFloat = 1
    }

    typealias CategoryInfo = (title: String, slug: String)
    var categoriesInfo: [CategoryInfo] = [] {
        didSet {
            let changed: Bool = (categoriesInfo.count != oldValue.count) || oldValue.enumerated().any { (index, info) in
                return info.title != categoriesInfo[index].title || info.slug != categoriesInfo[index].slug
            }
            if changed {
                updateCategoryViews()
            }
        }
    }

    fileprivate var buttonCategoryLookup: [UIButton: CategoryInfo] = [:]
    fileprivate var categoryButtons: [UIButton] = []

    fileprivate class func buttonTitle(_ category: String) -> NSAttributedString {
        let attrs: [String: Any] = [
            NSFontAttributeName: UIFont.defaultFont(),
            NSForegroundColorAttributeName: UIColor.black
        ]
        let attributedString = NSAttributedString(string: category, attributes: attrs)
        return attributedString
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        style()
        bindActions()
        arrange()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    fileprivate func style() {
        backgroundColor = .white
    }

    fileprivate func bindActions() {
    }

    fileprivate func arrange() {
    }

    @objc
    func categoryButtonTapped(_ button: UIButton) {
        guard let categoryInfo = buttonCategoryLookup[button] else { return }

        let responder: CategoryListCellResponder? = findResponder()
        responder?.categoryListCellTapped(slug: categoryInfo.slug, name: categoryInfo.title)
    }

    fileprivate func updateCategoryViews() {
        for view in categoryButtons {
            view.removeFromSuperview()
        }

        buttonCategoryLookup = [:]
        categoryButtons = categoriesInfo.map { categoryInfo in
            let button = UIButton()
            buttonCategoryLookup[button] = categoryInfo
            button.backgroundColor = .greyF2()
            button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
            let attributedString = CategoryListCell.buttonTitle(categoryInfo.title)
            button.setAttributedTitle(attributedString, for: .normal)

            return button
        }

        var prevView: UIView? = nil
        for view in categoryButtons {
            contentView.addSubview(view)

            view.snp.makeConstraints { make in
                make.top.bottom.equalTo(contentView)

                if let prevView = prevView {
                    make.leading.equalTo(prevView.snp.trailing).offset(Size.spacing)
                    make.width.equalTo(prevView)
                }
                else {
                    make.leading.equalTo(contentView)
                }
            }

            prevView = view
        }

        if let prevView = prevView {
            prevView.snp.makeConstraints { make in
                make.trailing.equalTo(contentView)
            }
        }
        setNeedsLayout()
    }

}
