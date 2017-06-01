////
///  BadgeCell.swift
//

import SnapKit


class BadgeCell: UICollectionViewCell {
    static let reuseIdentifier = "BadgeCell"

    struct Size {
        static let imageInsets = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 0)
        static let grayInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        static let labelMargin: CGFloat = 20
    }

    var title: String? {
        set { label.text = newValue }
        get { return label.text }
    }
    var attributedTitle: NSAttributedString? {
        set { label.attributedText = newValue }
        get { return label.attributedText }
    }
    var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }
    var url: URL?

    fileprivate let label = ElloTextView()
    fileprivate let imageView = UIImageView()
    fileprivate let grayLine = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        style()
        arrange()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = ""
        imageView.image = nil
        url = nil
    }

    fileprivate func style() {
        label.textViewDelegate = self
        label.backgroundColor = .clear
        label.isEditable = false
        label.allowsEditingTextAttributes = false
        label.isSelectable = false
        label.textColor = .black
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        grayLine.backgroundColor = .greyE5()
    }

    fileprivate func arrange() {
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        contentView.addSubview(grayLine)

        imageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(contentView).inset(Size.imageInsets)
            imageView.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        }
        label.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(imageView.snp.trailing).offset(Size.labelMargin)
            make.trailing.lessThanOrEqualTo(contentView)
        }
        grayLine.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(contentView).inset(Size.grayInsets)
            make.height.equalTo(1)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        imageView.layer.cornerRadius = max(imageView.frame.width / 2, imageView.frame.height / 2)
    }
}

extension BadgeCell: ElloTextViewDelegate {

    func textViewTapped(_ link: String, object: ElloAttributedObject) {
        switch object {
        case let .attributedCategory(category):
            let responder: CategoryResponder? = findResponder()
            responder?.categoryTapped(category)
        default: break
        }
    }

    func textViewTappedDefault() {
        if let url = url {
            postNotification(ExternalWebNotification, value: url.absoluteString)
        }
    }
}
