////
///  ProfileLinksView.swift
//

import SnapKit


public class ProfileLinksView: ProfileBaseView {
    public struct Size {
        static let margins = UIEdgeInsets(top: 12, left: 15, bottom: 15, right: 15)
        static let iconInsets = UIEdgeInsets(all: 15)
        static let iconSize = CGSize(width: 22, height: 22)
        static let iconMargins: CGFloat = 10
        static let verticalLinkMargin: CGFloat = 3
        static let horizLinkButtonMargin: CGFloat = 5
        static let linkHeight: CGFloat = 26
    }

    public var externalLinks: [ExternalLink] = [] {
        didSet {
            setNeedsUpdateConstraints()
            rearrangeLinks()
        }
    }

    weak var webLinkDelegate: WebLinkDelegate?

    private var linksBox = UIView()
    private var iconsBox = UIView()
    private var linkButtons: [UIButton] = []
    private var iconButtons: [UIButton] = []
    private var buttonLinks: [UIButton: ExternalLink] = [:]

    var onHeightMismatch: OnHeightMismatch?
}

extension ProfileLinksView {

    override func style() {
        backgroundColor = .whiteColor()
        iconsBox.backgroundColor = .whiteColor()
    }

    override func bindActions() {
    }

    override func setText() {
    }

    override func arrange() {
        addSubview(linksBox)
        addSubview(iconsBox)

        linksBox.snp_makeConstraints { make in
            make.leading.top.bottom.equalTo(self).inset(Size.margins)
            make.trailing.equalTo(iconsBox.snp_leading).offset(-Size.horizLinkButtonMargin)
        }

        iconsBox.snp_makeConstraints { make in
            make.trailing.top.bottom.equalTo(self).inset(Size.iconInsets)
            make.width.equalTo(Size.iconSize.width)
        }
    }
}

extension ProfileLinksView {
    func prepareForReuse() {
        externalLinks = []
        webLinkDelegate = nil
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

        let textLinks = externalLinks.filter{$0.iconURL == nil && $0.text != ""}
        let iconLinks = externalLinks.filter{$0.iconURL != nil}

        let (perRow, iconsBoxWidth) = ProfileLinksSizeCalculator.calculateIconsBoxWidth(externalLinks, maxWidth: bounds.width)

        iconsBox.snp_updateConstraints { make in
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

    private func addIconButton(externalLink: ExternalLink, iconsCount: Int, prevIcon: UIButton?, prevRow: UIView?, perRow: Int, hasTextLinks: Bool) -> UIButton {
        let button = UIButton()
        button.addTarget(self, action: #selector(buttonTapped(_:)), forControlEvents: .TouchUpInside)
        buttonLinks[button] = externalLink

        iconsBox.addSubview(button)
        iconButtons.append(button)

        button.layer.cornerRadius = Size.iconSize.width / 2
        button.backgroundColor = .greyE5()
        button.snp_makeConstraints { make in
            make.size.equalTo(Size.iconSize)

            let direction = hasTextLinks ? make.trailing : make.leading

            switch iconsCount % perRow {
            case 0:
                direction.equalTo(iconsBox)
            default:
                let prevDirection = hasTextLinks ? prevIcon!.snp_leading : prevIcon!.snp_trailing
                let offset = hasTextLinks ? -Size.iconMargins : Size.iconMargins
                direction.equalTo(prevDirection).offset(offset)
            }

            if let prevRow = prevRow {
                make.top.equalTo(prevRow.snp_bottom).offset(Size.iconMargins)
            }
            else {
                make.top.equalTo(iconsBox)
            }
        }

        button.pin_setImageFromURL(externalLink.iconURL!)
        return button
    }

    private func addLinkButton(externalLink: ExternalLink, prevLink: UIButton?) -> UIButton {
        let button = UIButton()
        button.addTarget(self, action: #selector(buttonTapped(_:)), forControlEvents: .TouchUpInside)
        buttonLinks[button] = externalLink

        linksBox.addSubview(button)
        linkButtons.append(button)

        button.snp_makeConstraints { make in
            make.leading.trailing.equalTo(linksBox)

            if let prevLink = prevLink {
                make.top.equalTo(prevLink.snp_bottom).offset(Size.verticalLinkMargin)
            }
            else {
                make.top.equalTo(linksBox)
            }
        }

        let attrs: [String: AnyObject] = [
            NSFontAttributeName: UIFont.defaultFont(),
            NSForegroundColorAttributeName: UIColor.greyA(),
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
        ]
        let highlightedAttrs: [String: AnyObject] = [
            NSFontAttributeName: UIFont.defaultFont(),
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
        ]
        button.setAttributedTitle(NSAttributedString(string: externalLink.text, attributes: attrs), forState: .Normal)
        button.setAttributedTitle(NSAttributedString(string: externalLink.text, attributes: highlightedAttrs), forState: .Highlighted)
        button.contentHorizontalAlignment = .Left
        return button
    }

    func buttonTapped(button: UIButton) {
        guard let
            externalLink = buttonLinks[button]
            else { return }

        let request = NSURLRequest(URL: externalLink.url)
        ElloWebViewHelper.handleRequest(request, webLinkDelegate: webLinkDelegate)
    }
}

extension ProfileLinksView: ProfileViewProtocol {}
