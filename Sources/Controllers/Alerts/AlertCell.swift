////
///  AlertCell.swift
//

import UIKit
import Foundation
import ElloUIFonts
import CoreGraphics

protocol AlertCellDelegate: class {
    func tappedOkButton()
    func tappedCancelButton()
}

class AlertCell: UITableViewCell {
    static let reuseIdentifier = "AlertCell"

    weak var delegate: AlertCellDelegate?

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var input: ElloTextField!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var okButton: StyledButton!
    @IBOutlet weak var cancelButton: StyledButton!
    let inputBorder = UIView()

    var onInputChanged: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        label.font = .defaultFont()
        label.textColor = .black
        label.textAlignment = .left

        input.backgroundColor = UIColor.white
        input.font = UIFont.defaultFont()
        input.textColor = UIColor.black
        input.tintColor = UIColor.black
        input.clipsToBounds = false

        inputBorder.backgroundColor = UIColor.black
        input.addSubview(inputBorder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        inputBorder.frame = input.bounds.fromBottom().grow(top: 1, sides: 10, bottom: 0)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        label.text = ""
        label.textColor = .black
        label.textAlignment = .left
        input.text = ""
        _ = input.resignFirstResponder()
    }
}

extension AlertCell {
    @IBAction func didUpdateInput() {
        onInputChanged?(input.text ?? "")
    }

    @IBAction func didTapOkButton() {
        delegate?.tappedOkButton()
    }

    @IBAction func didTapCancelButton() {
        delegate?.tappedCancelButton()
    }

}

extension AlertCell {
    class func nib() -> UINib {
        return UINib(nibName: "AlertCell", bundle: .none)
    }
}
