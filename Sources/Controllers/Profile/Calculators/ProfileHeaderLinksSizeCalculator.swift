////
///  ProfileHeaderLinksSizeCalculator.swift
//

import PromiseKit


class ProfileHeaderLinksSizeCalculator: CellSizeCalculator {

    static func calculateHeight(_ externalLinks: [ExternalLink], width: CGFloat) -> CGFloat {
        let iconsCount = externalLinks.filter({ $0.iconURL != nil }).count
        let (perRow, _) = ProfileHeaderLinksSizeCalculator.calculateIconsBoxWidth(
            externalLinks,
            width: width
        )
        let iconsRows = max(0, ceil(Double(iconsCount) / Double(perRow)))
        let iconsHeight = CGFloat(iconsRows) * ProfileHeaderLinksCell.Size.iconSize.height
            + CGFloat(max(0, iconsRows - 1)) * ProfileHeaderLinksCell.Size.iconMargins

        let textLinksCount = externalLinks.filter { $0.iconURL == nil && !$0.text.isEmpty }.count
        let linksHeight = CGFloat(textLinksCount) * ProfileHeaderLinksCell.Size.linkHeight
            + CGFloat(max(0, textLinksCount - 1)) * ProfileHeaderLinksCell.Size.verticalLinkMargin
        return ProfileHeaderLinksCell.Size.margins.tops + max(iconsHeight, linksHeight)
    }

    static func calculateIconsBoxWidth(_ externalLinks: [ExternalLink], width: CGFloat) -> (
        Int, CGFloat
    ) {
        let iconsCount = externalLinks.filter({ $0.iconURL != nil }).count
        let textLinksCount = externalLinks.filter { $0.iconURL == nil && !$0.text.isEmpty }.count
        let cellWidth = max(0, width - ProfileHeaderLinksCell.Size.margins.sides)
        let perRow: Int
        let iconsBoxWidth: CGFloat
        if textLinksCount > 0 {
            perRow = 3
            let maxNumberOfIconsInRow = CGFloat(min(perRow, iconsCount))
            let maxIconsWidth = ProfileHeaderLinksCell.Size.iconSize.width * maxNumberOfIconsInRow
            let iconsMargins = ProfileHeaderLinksCell.Size.iconMargins
                * max(0, maxNumberOfIconsInRow - 1)
            iconsBoxWidth = max(0, maxIconsWidth + iconsMargins)
        }
        else {
            iconsBoxWidth = cellWidth
            perRow = Int(
                cellWidth / (
                    ProfileHeaderLinksCell.Size.iconSize.width
                        + ProfileHeaderLinksCell.Size.iconMargins
                )
            )
        }

        return (perRow, iconsBoxWidth)
    }

    override func process() {
        guard
            let user = cellItem.jsonable as? User,
            let externalLinks = user.externalLinksList, externalLinks.count > 0
        else {
            assignCellHeight(all: 0)
            return
        }

        assignCellHeight(
            all: ProfileHeaderLinksSizeCalculator.calculateHeight(externalLinks, width: width)
        )
    }
}
