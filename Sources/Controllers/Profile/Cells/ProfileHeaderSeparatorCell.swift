////
///  ProfileHeaderSeparatorCell.swift
//

import SnapKit


class ProfileHeaderSeparatorCell: ProfileHeaderCell {
    static let reuseIdentifier = "ProfileHeaderSeparatorCell"

    struct Size {
        static let height: CGFloat = 1
        static let grayInsets: CGFloat = 15
    }

    private let grayLine = UIView()

    override func style() {
        backgroundColor = .white
        grayLine.backgroundColor = .greyE5
    }

    override func arrange() {
        contentView.addSubview(grayLine)

        grayLine.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView)
            make.leading.trailing.equalTo(contentView).inset(Size.grayInsets)
        }
    }
}
