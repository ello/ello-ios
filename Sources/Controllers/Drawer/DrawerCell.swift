////
///  DrawerCell.swift
//

class DrawerCell: UITableViewCell {
    static let reuseIdentifier = "DrawerCell"
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var line: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .grey6()
        line.backgroundColor = .grey5()
        label.font = UIFont.defaultFont()
        label.textColor = .white
    }
}

extension DrawerCell {
    class func nib() -> UINib {
        return UINib(nibName: "DrawerCell", bundle: .none)
    }
}
