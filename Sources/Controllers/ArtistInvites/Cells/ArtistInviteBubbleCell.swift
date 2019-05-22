////
///  ArtistInviteBubbleCell.swift
//

import SnapKit
import SVGKit
import PINRemoteImage


class ArtistInviteBubbleCell: CollectionViewCell, ArtistInviteConfigurableCell {
    static let reuseIdentifier = "ArtistInviteBubbleCell"

    struct Size {
        static let headerImageHeight: CGFloat = 230
        static let infoTotalHeight: CGFloat = 86

        static let logoImageSize = CGSize(width: 270, height: 152)
        static let cornerRadius: CGFloat = 5
        static let bubbleMargins = UIEdgeInsets(top: 0, left: 15, bottom: 15, right: 15)
        static let infoMargins = UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15)
        static let titleStatusSpacing: CGFloat = 21.5
        static let dotYOffset: CGFloat = -1
        static let dotStatusSpacing: CGFloat = 15
        static let statusTypeDateSpacing: CGFloat = 10
        static let descriptionMargins = UIEdgeInsets(top: 20, left: 15, bottom: 15, right: 15)
    }

    struct Config {
        var title: String = ""
        var inviteType: String = ""
        var status: ArtistInvite.Status = .open
        var shortDescription: String = ""
        var longDescription: String = ""
        var headerURL: URL?
        var logoURL: URL?
        var openedAt: Date?
        var closedAt: Date?
        var isInCountdown: Bool { return status == .open }
    }

    var config = Config() {
        didSet {
            updateConfig()
        }
    }

    private let bg = UIView()
    private let headerImage = PINAnimatedImageView()
    private let headerOverlay = UIView()
    private let logoImage = UIImageView()
    private let titleLabel = StyledLabel(style: .artistInviteTitle)
    private let statusImage = UIImageView()
    private let statusLabel = StyledLabel()
    private let inviteTypeLabel = StyledLabel(style: .gray)
    private let dateLabel = StyledLabel(style: .gray)
    private let descriptionWebView = ElloWebView()

    static func calculateDynamicHeights(title: String, inviteType: String, cellWidth: CGFloat) -> CGFloat {
        let textWidth = cellWidth - Size.bubbleMargins.sides - Size.infoMargins.sides
        let height1 = NSAttributedString(label: title, style: .artistInviteTitle, lineBreakMode: .byWordWrapping).heightForWidth(textWidth)
        let height2 = NSAttributedString(label: inviteType, style: .gray, lineBreakMode: .byWordWrapping).heightForWidth(textWidth)
        return height1 + height2
    }

    override func bindActions() {
        descriptionWebView.delegate = self
    }

    override func style() {
        bg.layer.cornerRadius = Size.cornerRadius
        bg.clipsToBounds = true
        bg.backgroundColor = .greyF2
        headerImage.contentMode = .scaleAspectFill
        headerImage.clipsToBounds = true
        headerOverlay.backgroundColor = .black
        headerOverlay.alpha = 0.3
        logoImage.contentMode = .scaleAspectFit
        logoImage.clipsToBounds = true
        titleLabel.isMultiline = true
        inviteTypeLabel.isMultiline = true
        descriptionWebView.scrollView.isScrollEnabled = false
        descriptionWebView.scrollView.scrollsToTop = false
        descriptionWebView.isUserInteractionEnabled = false
    }

    override func arrange() {
        contentView.addSubview(bg)

        bg.addSubview(headerImage)
        bg.addSubview(headerOverlay)
        bg.addSubview(logoImage)
        bg.addSubview(titleLabel)
        bg.addSubview(statusImage)
        bg.addSubview(statusLabel)
        bg.addSubview(inviteTypeLabel)
        bg.addSubview(dateLabel)
        bg.addSubview(descriptionWebView)

        bg.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(Size.bubbleMargins)
        }

        headerImage.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(bg)
            make.height.equalTo(Size.headerImageHeight)
        }

        headerOverlay.snp.makeConstraints { make in
            make.edges.equalTo(headerImage)
        }

        logoImage.snp.makeConstraints { make in
            make.center.equalTo(headerImage)
            make.size.equalTo(Size.logoImageSize).priority(Priority.medium)
            make.width.lessThanOrEqualTo(bg).priority(Priority.required)
            make.height.equalTo(logoImage.snp.width).multipliedBy(Size.logoImageSize.height / Size.logoImageSize.width).priority(Priority.required)
        }
        logoImage.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .vertical)
        logoImage.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(bg).inset(Size.infoMargins)
            make.top.equalTo(headerImage.snp.bottom).offset(Size.infoMargins.top)
        }

        statusImage.snp.makeConstraints { make in
            make.centerY.equalTo(statusLabel).offset(Size.dotYOffset)
            make.leading.equalTo(titleLabel)
        }

        statusLabel.snp.makeConstraints { make in
            make.leading.equalTo(statusImage.snp.trailing).offset(Size.dotStatusSpacing)
            make.top.equalTo(titleLabel.snp.bottom).offset(Size.titleStatusSpacing)
        }

        inviteTypeLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(statusLabel.snp.bottom).offset(Size.statusTypeDateSpacing)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(inviteTypeLabel.snp.bottom).offset(Size.statusTypeDateSpacing)
            make.leading.trailing.equalTo(titleLabel)
        }

        descriptionWebView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(bg).inset(Size.descriptionMargins)
            make.top.equalTo(dateLabel.snp.bottom).offset(Size.descriptionMargins.top)
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
        timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(updateDateText), userInfo: nil, repeats: true)
    }

    private func stopTimer() {
        guard let timer = timer else { return }
        timer.invalidate()
        self.timer = nil
    }

    func updateConfig() {
        titleLabel.text = config.title
        inviteTypeLabel.text = config.inviteType

        statusImage.image = config.status.image
        statusLabel.text = config.status.text
        statusLabel.style = config.status.labelStyle
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

        let html = StreamTextCellHTML.artistInviteHTML(config.shortDescription)
        descriptionWebView.loadHTMLString(html, baseURL: URL(string: "/"))
    }

    @objc
    private func updateDateText() {
        dateLabel.text = config.dateText()
    }
}

extension ArtistInviteBubbleCell.Config {
    static func fromArtistInvite(_ artistInvite: ArtistInvite) -> ArtistInviteBubbleCell.Config {
        var config = ArtistInviteBubbleCell.Config()
        config.title = artistInvite.title
        config.shortDescription = artistInvite.shortDescription
        config.longDescription = artistInvite.longDescription
        config.inviteType = artistInvite.inviteType
        config.status = artistInvite.status
        config.openedAt = artistInvite.openedAt
        config.closedAt = artistInvite.closedAt
        config.headerURL = artistInvite.headerImage?.largeOrBest?.url
        config.logoURL = artistInvite.logoImage?.optimized?.url
        return config
    }
}

extension ArtistInvite.Status {
    var text: String {
        switch self {
        case .preview: return InterfaceString.ArtistInvites.PreviewStatus
        case .upcoming: return InterfaceString.ArtistInvites.UpcomingStatus
        case .open: return InterfaceString.ArtistInvites.OpenStatus
        case .selecting: return InterfaceString.ArtistInvites.SelectingStatus
        case .closed: return InterfaceString.ArtistInvites.ClosedStatus
        }
    }

    var image: UIImage? {
        switch self {
        case .preview: return SVGKImage(named: "artist_invite_status_preview.svg").uiImage.withRenderingMode(.alwaysOriginal)
        case .upcoming: return SVGKImage(named: "artist_invite_status_upcoming.svg").uiImage.withRenderingMode(.alwaysOriginal)
        case .open: return SVGKImage(named: "artist_invite_status_open.svg").uiImage.withRenderingMode(.alwaysOriginal)
        case .selecting: return SVGKImage(named: "artist_invite_status_selecting.svg").uiImage.withRenderingMode(.alwaysOriginal)
        case .closed: return SVGKImage(named: "artist_invite_status_closed.svg").uiImage.withRenderingMode(.alwaysOriginal)
        }
    }

    var labelStyle: StyledLabel.Style {
        switch self {
        case .preview: return .artistInvitePreview
        case .upcoming: return .artistInviteUpcoming
        case .open: return .artistInviteOpen
        case .selecting: return .artistInviteSelecting
        case .closed: return .artistInviteClosed
        }
    }
}

extension StyledLabel.Style {
    static let artistInviteTitle = StyledLabel.Style(
        textColor: .black,
        fontFamily: .artistInviteTitle
        )
    static let artistInvitePreview = StyledLabel.Style(
        textColor: UIColor(hex: 0x0409FE)
        )
    static let artistInviteUpcoming = StyledLabel.Style(
        textColor: UIColor(hex: 0xC000FF)
        )
    static let artistInviteOpen = StyledLabel.Style(
        textColor: UIColor(hex: 0x00D100)
        )
    static let artistInviteSelecting = StyledLabel.Style(
        textColor: UIColor(hex: 0xFDB02A)
        )
    static let artistInviteClosed = StyledLabel.Style(
        textColor: UIColor(hex: 0xFE0404)
        )
}

extension ArtistInviteBubbleCell.Config {
    func dateText() -> String {
        switch status {
        case .preview, .upcoming:
            return ""
        case .selecting:
            return InterfaceString.ArtistInvites.Selecting
        case .closed:
            guard let closedAt = closedAt else { return "" }
            return InterfaceString.ArtistInvites.Ended(closedAt.monthDayYear())
        default: break
        }

        if let closedAt = closedAt {
            return dateTextRemaining(closedAt)
        }
        return ""
    }

    private func dateTextRemaining(_ closedAt: Date) -> String {
        let now = Globals.now
        let secondsRemaining = Int(closedAt.timeIntervalSince(now))
        let daysRemaining = Int(secondsRemaining / 24 / 3600)
        if daysRemaining > 1 {
            return InterfaceString.ArtistInvites.DaysRemaining(daysRemaining)
        }
        return InterfaceString.ArtistInvites.Countdown(secondsRemaining)
    }

}

extension ArtistInviteBubbleCell: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if let scheme = request.url?.scheme, scheme == "default" {
            let responder: StreamCellResponder? = findResponder()
            responder?.streamCellTapped(cell: self)
            return false
        }
        else {
            return ElloWebViewHelper.handle(request: request, origin: self)
        }
    }
}
