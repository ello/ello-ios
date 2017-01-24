////
///  UserListItemCell.swift
//

import Foundation

class UserListItemCell: UICollectionViewCell {
    static let reuseIdentifier = "UserListItemCell"

    weak var avatarButton: AvatarButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    weak var relationshipControl: RelationshipControl!
    weak var userDelegate: UserDelegate?
    var bottomBorder = CALayer()

    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    func setUser(_ user: User?) {
        avatarButton.setUserAvatarURL(user?.avatarURL())

        relationshipControl.userId = user?.id ?? ""
        relationshipControl.userAtName = user?.atName ?? ""
        relationshipControl.relationshipPriority = user?.relationshipPriority ?? .none

        usernameLabel.text = user?.atName
        nameLabel.text = user?.name
    }

    fileprivate func style() {
        usernameLabel.font = UIFont.defaultBoldFont(18)
        usernameLabel.textColor = UIColor.black
        usernameLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail

        nameLabel.font = UIFont.defaultFont()
        nameLabel.textColor = UIColor.greyA()
        nameLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail

        // bottom border
        bottomBorder.backgroundColor = UIColor.greyF1().cgColor
        self.layer.addSublayer(bottomBorder)
    }

    override func layoutSubviews() {
        bottomBorder.frame = CGRect(x: 0, y: self.bounds.height - 1, width: self.bounds.width, height: 1)
        super.layoutSubviews()
    }

    @IBAction func userTapped(_ sender: AvatarButton) {
        userDelegate?.userTappedAuthor(cell: self)
    }
}
