////
///  ModeratorView.swift
//

class ModeratorView: View {
    struct Size {
        static let height: CGFloat = 80
        static let outerMargin: CGFloat = 15
        static let avatarSpacing: CGFloat = 30
        static let nameSpacing: CGFloat = 5
    }

    private let user: User
    private let avatarButton = AvatarButton()
    private let usernameButton = StyledButton(style: .clearBlackLarge)
    private let nameLabel = StyledLabel(style: .gray)
    private let relationshipControl = RelationshipControl()
    private let line = Line(color: .greyE5)

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: Size.height)
    }

    required init(user: User) {
        self.user = user
        super.init(frame: .zero)

        usernameButton.title = user.atName
        nameLabel.text = user.name
        avatarButton.setUserAvatarURL(user.avatarURL())

        relationshipControl.userId = user.id
        relationshipControl.userAtName = user.atName
        relationshipControl.relationshipPriority = user.relationshipPriority
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    override func bindActions() {
        usernameButton.addTarget(self, action: #selector(userTapped), for: .touchUpInside)
        avatarButton.addTarget(self, action: #selector(userTapped), for: .touchUpInside)
    }

    override func arrange() {
        addSubview(avatarButton)
        addSubview(usernameButton)
        addSubview(nameLabel)
        addSubview(relationshipControl)
        addSubview(line)

        avatarButton.snp.makeConstraints { make in
            make.leading.equalTo(self)
            make.centerY.equalTo(self)
            make.size.equalTo(AvatarButton.Size.normalSize)
        }

        let labelCenteringGuide = UILayoutGuide()
        addLayoutGuide(labelCenteringGuide)

        usernameButton.snp.makeConstraints { make in
            make.leading.equalTo(avatarButton.snp.trailing).offset(Size.avatarSpacing)
            make.trailing.lessThanOrEqualTo(relationshipControl.snp.leading)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(usernameButton)
            make.top.equalTo(usernameButton.snp.bottom).offset(Size.nameSpacing)
            make.trailing.lessThanOrEqualTo(relationshipControl.snp.leading)
        }

        labelCenteringGuide.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.top.equalTo(usernameButton)
            make.bottom.equalTo(nameLabel)
        }

        relationshipControl.snp.makeConstraints { make in
            make.trailing.equalTo(self)
            make.centerY.equalTo(self)
        }

        line.snp.makeConstraints { make in
            make.leading.equalTo(usernameButton)
            make.trailing.bottom.equalTo(self)
        }
    }

    @objc
    private func userTapped() {
        let responder: UserTappedResponder? = findResponder()
        responder?.userTapped(user)
    }
}
