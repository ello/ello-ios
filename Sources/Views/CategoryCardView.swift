////
///  CategoryCardView.swift
//

class CategoryCardView: UIView {

    let info: CategoryCardListView.CategoryInfo

    let overlay = UIView()
    let button = UIButton()

    fileprivate static let selectedAlpha: CGFloat = 0.8
    fileprivate static let normalAlpha: CGFloat = 0.6

    fileprivate var _selected = false
    var selected: Bool {
        set {
            _selected = newValue
            animate {
                self.overlay.alpha = newValue ? CategoryCardView.selectedAlpha : CategoryCardView.normalAlpha
            }
        }
        get { return _selected }
    }

    init(frame: CGRect, info: CategoryCardListView.CategoryInfo) {
        self.info = info

        super.init(frame: frame)
        style()
        arrange()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func style() {
        backgroundColor = .black

        overlay.backgroundColor = .black
        overlay.alpha = CategoryCardView.normalAlpha

        button.titleLabel?.numberOfLines = 0
        let attributedString = NSAttributedString(info.title, color: .white, alignment: .center)
        button.setAttributedTitle(attributedString, for: .normal)
    }

    fileprivate func arrange() {
        if let url = info.imageURL {
            let imageView = UIImageView()
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.pin_setImage(from: url as URL!)
            addSubview(imageView)
            imageView.snp.makeConstraints { $0.edges.equalTo(self) }
        }

        addSubview(overlay)
        addSubview(button)

        overlay.snp.makeConstraints { $0.edges.equalTo(self) }
        button.snp.makeConstraints { $0.edges.equalTo(self).inset(5) }
    }
}
