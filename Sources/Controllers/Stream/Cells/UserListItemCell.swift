////
///  UserListItemCell.swift
//

class UserListItemCell: CollectionViewCell {
    static let reuseIdentifier = "UserListItemCell"

    @IBOutlet weak var avatarButton: AvatarButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var relationshipControl: RelationshipControl!
    var bottomBorder = CALayer()

    func setUser(_ user: User?) {
        avatarButton.setUserAvatarURL(user?.avatarURL())

        relationshipControl.userId = user?.id ?? ""
        relationshipControl.userAtName = user?.atName ?? ""
        relationshipControl.relationshipPriority = user?.relationshipPriority ?? .none

        usernameLabel.text = user?.atName
        nameLabel.text = user?.name
    }

    override func arrange() {
        self.layer.addSublayer(bottomBorder)
    }

    override func style() {
        usernameLabel.font = UIFont.defaultBoldFont(18)
        usernameLabel.textColor = UIColor.black
        usernameLabel.lineBreakMode = .byTruncatingTail

        nameLabel.font = UIFont.defaultFont()
        nameLabel.textColor = UIColor.greyA
        nameLabel.lineBreakMode = .byTruncatingTail

        // bottom border
        bottomBorder.backgroundColor = UIColor.greyF1.cgColor
    }

    override func layoutSubviews() {
        bottomBorder.frame = CGRect(
            x: 0,
            y: self.bounds.height - 1,
            width: self.bounds.width,
            height: 1
        )
        super.layoutSubviews()
    }

    @IBAction func userTapped(_ sender: AvatarButton) {
        let responder: UserResponder? = findResponder()
        responder?.userTappedAuthor(cell: self)
    }
}
