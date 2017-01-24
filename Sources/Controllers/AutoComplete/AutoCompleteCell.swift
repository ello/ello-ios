////
///  AutoCompleteCell.swift
//

class AutoCompleteCell: UITableViewCell {
    static let reuseIdentifier = "AutoCompleteCell"

    @IBOutlet weak var name: UILabel!
    weak var avatar: AvatarButton!
    @IBOutlet weak var line: UIView!

    struct Size {
        static let height: CGFloat = 49
    }
}

extension AutoCompleteCell {
    class func nib() -> UINib {
        return UINib(nibName: "AutoCompleteCell", bundle: .none)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatar.setDefaultImage()
    }
}
