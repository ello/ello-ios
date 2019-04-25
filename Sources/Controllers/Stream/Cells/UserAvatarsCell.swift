////
///  UserAvatarsCell.swift
//

class UserAvatarsCell: UICollectionViewCell {
    static let reuseIdentifier = "UserAvatarsCell"

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var avatarsView: UIView!
    var users = [User]()
    var avatarButtons = [AvatarButton]()
    var maxAvatars: Int {
        return Int(floor((Globals.windowSize.width - seeAllButton.frame.size.width - 65) / 40.0))
    }
    var userAvatarCellModel: UserAvatarCellModel? {
        didSet {
            users = userAvatarCellModel?.users ?? []
            updateAvatars()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    private func style() {
        loadingLabel.textColor = UIColor.greyA
        loadingLabel.font = UIFont.defaultFont()
        seeAllButton.titleLabel?.textColor = UIColor.greyA
        seeAllButton.titleLabel?.font = UIFont.defaultFont()
    }

    private func updateAvatars() {
        clearButtons()
        let numToDisplay = min(users.count, maxAvatars)
        seeAllButton.isHidden = users.count <= numToDisplay
        let usersToDisplay = users[0..<numToDisplay]
        var startX: CGFloat = 0
        for user in usersToDisplay {
            let ab = AvatarButton()
            ab.frame = CGRect(origin: CGPoint(x: startX, y: 0), size: AvatarButton.Size.smallSize)
            ab.setUserAvatarURL(user.avatarURL())
            ab.addTarget(self, action: #selector(UserAvatarsCell.avatarTapped(_:)), for: .touchUpInside)
            avatarsView.addSubview(ab)
            avatarButtons.append(ab)
            startX += 40
        }
    }

    private func clearButtons() {
        for ab in avatarButtons {
            ab.removeFromSuperview()
        }
        avatarButtons = [AvatarButton]()
    }

    @IBAction func seeMoreTapped(_ sender: UIButton) {
        guard
            let model = userAvatarCellModel
        else { return }

        let responder: SimpleStreamResponder? = findResponder()
        responder?.showSimpleStream(boxedEndpoint: BoxedElloAPI(endpoint: model.endpoint), title: model.seeMoreTitle)
    }

    @IBAction func avatarTapped(_ sender: AvatarButton) {
        guard
            let index = avatarButtons.firstIndex(of: sender),
            users.count > index
        else { return }

        let user = users[index]
        let responder: UserResponder? = findResponder()
        responder?.userTapped(user: user)
    }
}
