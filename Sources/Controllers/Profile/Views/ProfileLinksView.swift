////
///  ProfileLinksView.swift
//

import SnapKit


class ProfileLinksView: ProfileBaseView {
    struct Size {
        static let margins = UIEdgeInsets(top: 12, left: 15, bottom: 15, right: 15)
        static let iconInsets = UIEdgeInsets(all: 15)
        static let iconSize = CGSize(width: 22, height: 22)
        static let iconMargins: CGFloat = 10
        static let verticalLinkMargin: CGFloat = 3
        static let horizLinkButtonMargin: CGFloat = 5
        static let linkHeight: CGFloat = 26
    }

    var externalLinks: [ExternalLink] = [] {
        didSet {
            setNeedsUpdateConstraints()
            rearrangeLinks()
        }
    }

    private var linksBox = UIView()
    private var iconsBox = UIView()
    private var linkButtons: [UIButton] = []
    private var iconButtons: [UIButton] = []
    private var buttonLinks: [UIButton: ExternalLink] = [:]

    var onHeightMismatch: OnHeightMismatch?

    override func style() {
        backgroundColor = .white
        iconsBox.backgroundColor = .white
    }

    override func arrange() {
        addSubview(linksBox)
        addSubview(iconsBox)

        linksBox.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(self).inset(Size.margins)
            make.trailing.equalTo(iconsBox.snp.leading).offset(-Size.horizLinkButtonMargin)
        }

        iconsBox.snp.makeConstraints { make in
            make.trailing.top.bottom.equalTo(self).inset(Size.iconInsets)
            make.width.equalTo(Size.iconSize.width)
        }
    }
}

extension ProfileLinksView {

    func prepareForReuse() {
        externalLinks = []
    }
}

extension ProfileLinksView {

    func rearrangeLinks() {
        guard bounds.width > 0 else { return }

        for view in linkButtons + iconButtons {
            view.removeFromSuperview()
        }
        linkButtons = []
        iconButtons = []

        var prevLink: UIButton?
        var prevIcon: UIButton?
        var prevRow: UIButton?
        var iconsCount = 0

        let textLinks = externalLinks.filter{$0.iconURL == nil && !$0.text.isEmpty}
        let iconLinks = externalLinks.filter{$0.iconURL != nil}

        let (perRow, iconsBoxWidth) = ProfileLinksSizeCalculator.calculateIconsBoxWidth(externalLinks, maxWidth: bounds.width)

        iconsBox.snp.updateConstraints { make in
            make.width.equalTo(iconsBoxWidth)
        }

        for textLink in textLinks {
            prevLink = addLinkButton(textLink, prevLink: prevLink)
        }

        for iconLink in iconLinks {
            prevIcon = addIconButton(iconLink, iconsCount: iconsCount, prevIcon: prevIcon, prevRow: prevRow, perRow: perRow, hasTextLinks: textLinks.count > 0)
            iconsCount += 1
            if iconsCount % perRow == 0 {
                prevRow = prevIcon
            }
        }

        let totalHeight: CGFloat
        if externalLinks.count == 0 {
            totalHeight = 0
        }
        else {
            totalHeight = ProfileLinksSizeCalculator.calculateHeight(externalLinks, maxWidth: bounds.width)
        }

        if totalHeight != frame.size.height {
            onHeightMismatch?(totalHeight)
        }
    }

    private func addIconButton(_ externalLink: ExternalLink, iconsCount: Int, prevIcon: UIButton?, prevRow: UIView?, perRow: Int, hasTextLinks: Bool) -> UIButton {
        let button = UIButton()
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        buttonLinks[button] = externalLink

        iconsBox.addSubview(button)
        iconButtons.append(button)

        button.layer.masksToBounds = true
        button.layer.cornerRadius = Size.iconSize.width / 2
        button.backgroundColor = .greyE5
        button.snp.makeConstraints { make in
            make.size.equalTo(Size.iconSize)

            let direction = hasTextLinks ? make.trailing : make.leading

            switch iconsCount % perRow {
            case 0:
                direction.equalTo(iconsBox)
            default:
                let prevDirection = hasTextLinks ? prevIcon!.snp.leading : prevIcon!.snp.trailing
                let offset = hasTextLinks ? -Size.iconMargins : Size.iconMargins
                direction.equalTo(prevDirection).offset(offset)
            }

            if let prevRow = prevRow {
                make.top.equalTo(prevRow.snp.bottom).offset(Size.iconMargins)
            }
            else {
                make.top.equalTo(iconsBox)
            }
        }

        button.pin_setImage(from: externalLink.iconURL! as URL!)
        return button
    }

    private func addLinkButton(_ externalLink: ExternalLink, prevLink: UIButton?) -> UIButton {
        let button = UIButton()
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        buttonLinks[button] = externalLink

        linksBox.addSubview(button)
        linkButtons.append(button)

        button.snp.makeConstraints { make in
            make.leading.trailing.equalTo(linksBox)

            if let prevLink = prevLink {
                make.top.equalTo(prevLink.snp.bottom).offset(Size.verticalLinkMargin)
            }
            else {
                make.top.equalTo(linksBox)
            }
        }

        button.setAttributedTitle(NSAttributedString(string: externalLink.text, attributes: [
            .font: UIFont.defaultFont(),
            .foregroundColor: UIColor.greyA,
            .underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
        ]), for: .normal)

        button.setAttributedTitle(NSAttributedString(string: externalLink.text, attributes: [
            .font: UIFont.defaultFont(),
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
        ]), for: .highlighted)

        button.contentHorizontalAlignment = .left
        return button
    }

    @objc
    func buttonTapped(_ button: UIButton) {
        guard
            let externalLink = buttonLinks[button]
            else { return }

        let request = URLRequest(url: externalLink.url as URL)
        ElloWebViewHelper.handle(request: request, origin: self)
    }
}
