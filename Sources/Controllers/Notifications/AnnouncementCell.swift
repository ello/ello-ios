////
///  AnnouncementCell.swift
//

import SnapKit
import PINRemoteImage


class AnnouncementCell: CollectionViewCell {
    static let reuseIdentifier = "AnnouncementCell"

    struct Size {
        static let margins: CGFloat = 15
        static let imageSize: CGFloat = 80
        static let textLeadingMargin: CGFloat = 15
        static let textVerticalMargin: CGFloat = 15
        static let closeButtonMargin: CGFloat = 15
        static let closeButtonSize: CGFloat = 50
    }

    struct Config {
        var title: String?
        var body: String?
        var imageURL: URL?
        var image: UIImage? // for testing
        var callToAction: String?
        var isStaffPreview: Bool = false

        init() {}
    }

    var config = Config() {
        didSet {
            updateConfig()
        }
    }

    private let blackView = UIView()
    private let imageView = PINAnimatedImageView()
    private let closeButton = UIButton()
    private let titleLabel = StyledLabel(style: .boldWhite)
    private let bodyLabel = StyledLabel(style: .white)
    private let callToActionButton = StyledButton(style: .whiteUnderlined)
    private var imageHeightConstraint: Constraint!

    override func style() {
        closeButton.setImages(.x, style: .white)
        contentView.backgroundColor = .white
        blackView.backgroundColor = .black

        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .vertical)
        titleLabel.isMultiline = true
        bodyLabel.isMultiline = true
        callToActionButton.contentHorizontalAlignment = .left
        callToActionButton.isUserInteractionEnabled = false
    }

    override func bindActions() {
        closeButton.addTarget(self, action: #selector(markAsRead), for: .touchUpInside)
    }

    override func arrange() {
        contentView.addSubview(blackView)
        contentView.addSubview(imageView)
        contentView.addSubview(closeButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(callToActionButton)

        blackView.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(UIEdgeInsets(top: 1))
        }
        imageView.snp.makeConstraints { make in
            make.top.leading.equalTo(contentView).inset(Size.margins)
            make.width.equalTo(Size.imageSize)
            make.bottom.lessThanOrEqualTo(contentView.snp.bottom).inset(Size.margins).priority(Priority.high)
            imageHeightConstraint = make.height.equalTo(0).priority(Priority.medium).constraint
        }
        closeButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(contentView)
            make.width.height.equalTo(Size.closeButtonSize)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(Size.textLeadingMargin)
            make.top.equalTo(imageView)
            make.trailing.equalTo(closeButton.snp.leading)
        }
        bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Size.textVerticalMargin)
            make.leading.trailing.equalTo(titleLabel)
        }
        callToActionButton.snp.makeConstraints { make in
            make.top.equalTo(bodyLabel.snp.bottom).offset(Size.textVerticalMargin)
            make.leading.trailing.equalTo(titleLabel)
        }
    }

    override func prepareForReuse() {
        config = Config()
    }

    private func updateConfig() {
        titleLabel.text = config.title
        bodyLabel.text = config.body
        callToActionButton.title = config.callToAction
        blackView.backgroundColor = config.isStaffPreview ? .red : .black

        if let url = config.imageURL {
            imageView.pin_setImage(from: url) { result in
                let height: CGFloat
                if let image = result.image {
                    let size = image.size
                    height = size.height * Size.imageSize / size.width
                }
                else {
                    height = 0
                }
                self.imageHeightConstraint.update(offset: height)
            }
        }
        else {
            imageView.pin_cancelImageDownload()
            let height: CGFloat
            if let image = config.image {
                imageView.image = image // for testing, nice to be able to assign an image sync'ly
                let size = image.size
                height = size.height * Size.imageSize / size.width
            }
            else {
                height = 0
            }
            imageHeightConstraint.update(offset: height)
        }
    }
}

extension AnnouncementCell {

    @objc
    func markAsRead() {
        let responder: AnnouncementCellResponder? = findResponder()
        responder?.markAnnouncementAsRead(cell: self)
    }
}
