////
///  ProfileHeaderNamesSizeCalculator.swift
//

import PromiseKit


class ProfileHeaderNamesSizeCalculator: CellSizeCalculator {

    override func process() {
        guard
            let user = cellItem.jsonable as? User
        else {
            assignCellHeight(all: 0)
            return
        }

        let nameFont = StyledLabel.Style.large.fontFamily.font
        let usernameFont = StyledLabel.Style.gray.fontFamily.font

        let viewWidth = width - ProfileHeaderNamesCell.Size.outerMargins.sides
        let maxSize = CGSize(width: viewWidth, height: CGFloat.greatestFiniteMagnitude)

        let nameSize: CGSize
        if user.name.isEmpty {
            nameSize = .zero
        }
        else {
            nameSize =
                user.name.boundingRect(
                    with: maxSize,
                    options: [],
                    attributes: [
                        .font: nameFont,
                    ],
                    context: nil
                ).size.integral
        }

        let usernameSize = user.atName.boundingRect(
            with: maxSize,
            options: [],
            attributes: [
                .font: usernameFont,
            ],
            context: nil
        ).size.integral

        let (height, _) = ProfileHeaderNamesCell.preferredHeight(
            nameSize: nameSize,
            usernameSize: usernameSize,
            width: width
        )
        let totalHeight = height + ProfileHeaderNamesCell.Size.outerMargins.tops
        assignCellHeight(all: totalHeight)
    }
}
