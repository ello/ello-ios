////
///  UserAvatarsCell.swift
//

import Foundation

class UserAvatarsCell: UICollectionViewCell {
    static let reuseIdentifier = "UserAvatarsCell"

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var avatarsView: UIView!
    var users = [User]()
    var avatarButtons = [AvatarButton]()
    var maxAvatars: Int {
        return Int(floor((UIWindow.windowWidth() - seeAllButton.frame.size.width - 65) / 40.0))
    }
    var userAvatarCellModel: UserAvatarCellModel? {
        didSet {
            if let model = userAvatarCellModel {
                users = model.users ?? [User]()
                updateAvatars()
            }
        }
    }
    weak var userDelegate: UserDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    fileprivate func style() {
        loadingLabel.textColor = UIColor.greyA()
        loadingLabel.font = UIFont.defaultFont()
        seeAllButton.titleLabel?.textColor = UIColor.greyA()
        seeAllButton.titleLabel?.font = UIFont.defaultFont()
    }

    fileprivate func updateAvatars() {
        clearButtons()
        let numToDisplay = min(users.count, maxAvatars)
        seeAllButton.isHidden = users.count <= numToDisplay
        let usersToDisplay = users[0..<numToDisplay]
        var startX = 0.0
        for user in usersToDisplay {
            let ab = AvatarButton()
            ab.frame = CGRect(x: startX, y: 0.0, width: 30.0, height: 30.0)
            ab.setUserAvatarURL(user.avatarURL())
            ab.addTarget(self, action: #selector(UserAvatarsCell.avatarTapped(_:)), for: UIControlEvents.touchUpInside)
            avatarsView.addSubview(ab)
            avatarButtons.append(ab)
            startX += 40.0
        }
    }

    fileprivate func clearButtons() {
        for ab in avatarButtons {
            ab.removeFromSuperview()
        }
        avatarButtons = [AvatarButton]()
    }

    @IBAction func seeMoreTapped(_ sender: UIButton) {
        guard
            let model = userAvatarCellModel,
            let endpoint = model.endpoint
        else { return }

        let responder = target(forAction: #selector(SimpleStreamResponder.showSimpleStream(boxedEndpoint:title:noResultsMessages:)), withSender: self) as? SimpleStreamResponder
        responder?.showSimpleStream(boxedEndpoint: BoxedElloAPI(endpoint: endpoint), title: model.seeMoreTitle, noResultsMessages: nil)
    }

    @IBAction func avatarTapped(_ sender: AvatarButton) {
        guard
            let index = avatarButtons.index(of: sender),
            users.count > index
        else { return }

        let user = users[index]
        userDelegate?.userTapped(user: user)
    }
}
