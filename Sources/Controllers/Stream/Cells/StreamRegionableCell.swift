////
///  StreamRegionableCell.swift
//

import Foundation

class StreamRegionableCell: UICollectionViewCell {
    var leftBorder = CALayer()

    override func awakeFromNib() {
        super.awakeFromNib()
        leftBorder.backgroundColor = UIColor.black.cgColor
    }

    func showBorder() {
        self.layer.addSublayer(leftBorder)
    }

    func hideBorder() {
        leftBorder.removeFromSuperlayer()
    }

    override func layoutSubviews() {
        leftBorder.frame = CGRect(x: 15, y: 0, width: 1, height: self.bounds.height)
        super.layoutSubviews()
    }
}
