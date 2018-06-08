////
///  AnnouncementCellSizeCalculator.swift
//

class AnnouncementCellSizeCalculator: CellSizeCalculator {
    static func calculateAnnouncementHeight(_ announcement: Announcement, cellWidth: CGFloat) -> CGFloat {
        let attributedTitle = NSAttributedString(label: announcement.header, style: .boldWhite)
        let attributedBody = NSAttributedString(label: announcement.body, style: .white)
        let attributedCTA = NSAttributedString(button: announcement.ctaCaption, style: .whiteUnderlined)

        let textWidth = cellWidth - AnnouncementCell.Size.margins - AnnouncementCell.Size.imageSize - AnnouncementCell.Size.textLeadingMargin - AnnouncementCell.Size.closeButtonSize
        var calcHeight: CGFloat = 0
        calcHeight += 2 * AnnouncementCell.Size.margins
        var textHeight: CGFloat = 0
        textHeight += attributedTitle.heightForWidth(textWidth)
        textHeight += AnnouncementCell.Size.textVerticalMargin
        textHeight += attributedBody.heightForWidth(textWidth)
        textHeight += AnnouncementCell.Size.textVerticalMargin
        textHeight += attributedCTA.heightForWidth(textWidth)

        let imageHeight: CGFloat
        if let attachment = announcement.preferredAttachment,
            let width = attachment.width.flatMap({ CGFloat($0) }),
            let height = attachment.height.flatMap({ CGFloat($0) })
        {
            imageHeight = height * AnnouncementCell.Size.imageSize / width
        }
        else {
            imageHeight = 0
        }
        return calcHeight + max(textHeight, imageHeight)
    }

    override func process() {
        guard let announcement = cellItem.jsonable as? Announcement else {
            finish()
            return
        }

        assignCellHeight(all: AnnouncementCellSizeCalculator.calculateAnnouncementHeight(announcement, cellWidth: width))
    }

}
