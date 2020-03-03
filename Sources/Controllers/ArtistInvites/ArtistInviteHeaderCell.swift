////
///  ArtistInviteHeaderCell.swift
//

import SnapKit
import PINRemoteImage


class ArtistInviteHeaderCell: CollectionViewCell, ArtistInviteConfigurableCell {
    static let reuseIdentifier = "ArtistInviteHeaderCell"

    struct Size {
        static let headerImageHeight: CGFloat = 220
        static let remainingTextHeight: CGFloat = 148

        static let logoImageSize = ArtistInviteBubbleCell.Size.logoImageSize
        static let textMargins = UIEdgeInsets(top: 20, left: 15, bottom: 30, right: 15)
        static let statusSpacing: CGFloat = 10
        static let inviteTypeSpacing: CGFloat = 30
        static let dateSpacing: CGFloat = 10
    }

    typealias Config = ArtistInviteBubbleCell.Config

    var config = Config() {
        didSet {
            updateConfig()
        }
    }

    private let headerImage = PINAnimatedImageView()
    private let headerOverlay = UIView()
    private let logoImage = UIImageView()
    private let titleLabel = StyledLabel(style: .artistInviteTitle)
    private let statusLabel = StyledLabel()
    private let inviteTypeLabel = StyledLabel(style: .artistInviteDetailInfo)
    private let dateLabel = StyledLabel(style: .artistInviteDetailInfo)

    static func calculateDynamicHeights(title: String, inviteType: String, cellWidth: CGFloat)
        -> CGFloat
    {
        let textWidth = cellWidth - Size.textMargins.sides
        let height1 = NSAttributedString(
            label: title,
            style: .artistInviteTitle,
            lineBreakMode: .byWordWrapping
        ).heightForWidth(textWidth)
        let height2 = NSAttributedString(
            label: inviteType,
            style: .artistInviteDetailInfo,
            lineBreakMode: .byWordWrapping
        ).heightForWidth(textWidth)
        return height1 + height2
    }

    override func style() {
        headerImage.contentMode = .scaleAspectFill
        headerImage.clipsToBounds = true
        headerOverlay.backgroundColor = .black
        headerOverlay.alpha = 0.3
        titleLabel.isMultiline = true
        inviteTypeLabel.isMultiline = true
        logoImage.contentMode = .scaleAspectFit
        logoImage.clipsToBounds = true
    }

    override func arrange() {
        contentView.addSubview(headerImage)
        contentView.addSubview(headerOverlay)
        contentView.addSubview(logoImage)
        contentView.addSubview(titleLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(inviteTypeLabel)
        contentView.addSubview(dateLabel)

        headerImage.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(contentView)
            make.height.equalTo(Size.headerImageHeight)
        }

        headerOverlay.snp.makeConstraints { make in
            make.edges.equalTo(headerImage)
        }

        logoImage.snp.makeConstraints { make in
            make.center.equalTo(headerImage)
            make.size.equalTo(Size.logoImageSize)
            make.width.lessThanOrEqualTo(contentView).priority(Priority.required)
            make.height.equalTo(logoImage.snp.width).multipliedBy(
                Size.logoImageSize.height / Size.logoImageSize.width
            ).priority(Priority.required)
        }
        logoImage.setContentCompressionResistancePriority(
            UILayoutPriority(rawValue: Priority.low.value),
            for: .vertical
        )
        logoImage.setContentCompressionResistancePriority(
            UILayoutPriority(rawValue: Priority.low.value),
            for: .horizontal
        )

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView).inset(Size.textMargins)
            make.top.equalTo(headerImage.snp.bottom).offset(Size.textMargins.top)
        }

        statusLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(Size.statusSpacing)
        }

        inviteTypeLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(statusLabel.snp.bottom).offset(Size.inviteTypeSpacing)
        }

        dateLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(inviteTypeLabel.snp.bottom).offset(Size.dateSpacing)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        config = Config()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if superview != nil && config.isInCountdown {
            startTimer()
        }
        else {
            stopTimer()
        }
    }

    private var timer: Timer?

    private func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(
            timeInterval: 0.25,
            target: self,
            selector: #selector(updateDateText),
            userInfo: nil,
            repeats: true
        )
    }

    private func stopTimer() {
        guard let timer = timer else { return }
        timer.invalidate()
        self.timer = nil
    }

    func updateConfig() {
        titleLabel.text = config.title
        statusLabel.text = config.status.text
        statusLabel.style = config.status.detailLabelStyle
        inviteTypeLabel.text = config.inviteType
        updateDateText()

        let images: [(URL?, UIImageView)] = [
            (config.headerURL, headerImage),
            (config.logoURL, logoImage),
        ]
        for (url, imageView) in images {
            if let url = url {
                imageView.pin_setImage(from: url)
            }
            else {
                imageView.pin_cancelImageDownload()
                imageView.image = nil
            }
        }
    }

    @objc
    private func updateDateText() {
        dateLabel.text = config.dateText()
    }
}

extension ArtistInvite.Status {
    var detailLabelStyle: StyledLabel.Style {
        switch self {
        case .preview: return .artistInviteDetailPreview
        case .upcoming: return .artistInviteDetailUpcoming
        case .open: return .artistInviteDetailOpen
        case .selecting: return .artistInviteDetailSelecting
        case .closed: return .artistInviteDetailClosed
        }
    }
}

extension StyledLabel.Style {
    static let artistInviteDetailInfo = StyledLabel.Style(
        textColor: .greyA,
        fontFamily: .artistInviteDetail
    )

    static let artistInviteDetailPreview = StyledLabel.Style(
        textColor: UIColor(hex: 0x0409FE),
        fontFamily: .artistInviteDetail
    )
    static let artistInviteDetailUpcoming = StyledLabel.Style(
        textColor: UIColor(hex: 0xC000FF),
        fontFamily: .artistInviteDetail
    )
    static let artistInviteDetailOpen = StyledLabel.Style(
        textColor: UIColor(hex: 0x00D100),
        fontFamily: .artistInviteDetail
    )
    static let artistInviteDetailSelecting = StyledLabel.Style(
        textColor: UIColor(hex: 0xFDB02A),
        fontFamily: .artistInviteDetail
    )
    static let artistInviteDetailClosed = StyledLabel.Style(
        textColor: UIColor(hex: 0xFE0404),
        fontFamily: .artistInviteDetail
    )
}
