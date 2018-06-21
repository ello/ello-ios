////
///  AutoCompleteCell.swift
//

class AutoCompleteCell: TableViewCell {
    static let reuseIdentifier = "AutoCompleteCell"
    struct Size {
        static let height: CGFloat = 49
        static let avatarLeading: CGFloat = 15
        static let nameLeading: CGFloat = 10
    }

    var name: String? {
        get { return nameLabel.text }
        set { nameLabel.text = newValue }
    }

    let avatar = AvatarButton()
    private let nameLabel = StyledLabel(style: .white)
    private let line = Line(color: .grey3)

    override func styleCell() {
        contentView.backgroundColor = .black
        selectionStyle = .none
    }

    override func arrange() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(avatar)
        contentView.addSubview(line)

        avatar.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(Size.avatarLeading)
            make.centerY.equalTo(contentView)
            make.size.equalTo(AvatarButton.Size.smallSize)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatar.snp.trailing).offset(Size.nameLeading)
            make.centerY.equalTo(contentView)
        }

        line.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(contentView)
        }
    }
}

extension AutoCompleteCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        avatar.setDefaultImage()
    }
}
