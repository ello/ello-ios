////
///  StreamRegionableCell.swift
//

class StreamRegionableCell: CollectionViewCell {
    var leftBorder = CALayer()

    override func style() {
        leftBorder.backgroundColor = UIColor.black.cgColor
    }

    func showBorder() {
        guard !(layer.sublayers ?? []).contains(leftBorder) else { return }
        layer.addSublayer(leftBorder)
    }

    func hideBorder() {
        guard (layer.sublayers ?? []).contains(leftBorder) else { return }
        leftBorder.removeFromSuperlayer()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        leftBorder.frame = CGRect(x: 15, y: 0, width: 1, height: self.bounds.height)
    }
}
