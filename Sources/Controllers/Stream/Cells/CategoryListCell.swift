////
///  CategoryListCell.swift
//

import SnapKit

class CategoryListCell: CollectionViewCell {
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

    private var buttonCategoryLookup: [UIButton: CategoryInfo] = [:]
    private var categoryButtons: [UIButton] = []

    private class func buttonTitle(_ category: String) -> NSAttributedString {
        let attributedString = NSAttributedString(string: category, attributes: [
            .font: UIFont.defaultFont(),
            .foregroundColor: UIColor.black
        ])
        return attributedString
    }

    override func style() {
        backgroundColor = .white
    }

    @objc
    func categoryButtonTapped(_ button: UIButton) {
        guard let categoryInfo = buttonCategoryLookup[button] else { return }

        let responder: CategoryListCellResponder? = findResponder()
        responder?.categoryListCellTapped(slug: categoryInfo.slug, name: categoryInfo.title)
    }

    private func updateCategoryViews() {
        for view in categoryButtons {
            view.removeFromSuperview()
        }

        buttonCategoryLookup = [:]
        categoryButtons = categoriesInfo.map { categoryInfo in
            let button = UIButton()
            buttonCategoryLookup[button] = categoryInfo
            button.backgroundColor = .greyF2
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
