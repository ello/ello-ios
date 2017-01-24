////
///  StreamSeeMoreCommentsCell.swift
//

import Foundation


class StreamSeeMoreCommentsCell: UICollectionViewCell {
    static let reuseIdentifier = "StreamSeeMoreCommentsCell"

    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var seeMoreButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    fileprivate func style() {
        buttonContainer.backgroundColor = .greyA()
        seeMoreButton.setTitleColor(UIColor.greyA(), for: .normal)
        seeMoreButton.backgroundColor = .white
        seeMoreButton.titleLabel?.font = .defaultFont()
    }

}
