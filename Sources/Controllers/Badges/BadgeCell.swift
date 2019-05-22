////
///  BadgeCell.swift
//

import SnapKit
import PINRemoteImage


class BadgeCell: CollectionViewCell {
    static let reuseIdentifier = "BadgeCell"

    struct Size {
        static let imageLeftMargin: CGFloat = 20
        static let imageSize = CGSize(width: 24, height: 24)
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
    var url: URL?
    var imageURL: URL? {
        didSet {
            guard let imageURL = imageURL else {
                imageView.pin_cancelImageDownload()
                imageView.image = nil
                return
            }
            imageView.pin_setImage(from: imageURL)
        }
    }

    private let label = ElloTextView()
    private let imageView = PINAnimatedImageView()
    private let grayLine = UIView()

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = ""
        imageView.image = nil
        url = nil
    }

    override func style() {
        label.textViewDelegate = self
        label.backgroundColor = .clear
        label.isEditable = false
        label.allowsEditingTextAttributes = false
        label.isSelectable = false
        label.textColor = .black
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        grayLine.backgroundColor = .greyE5
    }

    override func arrange() {
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        contentView.addSubview(grayLine)

        imageView.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(Size.imageLeftMargin)
            make.centerY.equalTo(contentView)
            make.size.equalTo(Size.imageSize)
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
