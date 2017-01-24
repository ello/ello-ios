////
///  StreamFooterButton.swift
//

class StreamFooterButton: UIButton {

    var attributedText: NSMutableAttributedString = NSMutableAttributedString(string: "")

    func setButtonTitleWithPadding(_ title: String?, titlePadding: CGFloat = 4.0, contentPadding: CGFloat = 5.0) {

        if let title = title {
            setButtonTitle(title, color: UIColor.greyA(), for: .normal)
            setButtonTitle(title, color: UIColor.black, for: .highlighted)
            setButtonTitle(title, color: UIColor.black, for: .selected)
        }

        titleEdgeInsets = UIEdgeInsets(top: 0.0, left: titlePadding, bottom: 0.0, right: -(titlePadding))
        contentEdgeInsets = UIEdgeInsets(top: 0.0, left: contentPadding, bottom: 0.0, right: contentPadding)
        sizeToFit()
    }

    fileprivate func setButtonTitle(_ title: String, color: UIColor, for state: UIControlState) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes = [
            NSFontAttributeName : UIFont.defaultFont(),
            NSForegroundColorAttributeName : color,
            NSParagraphStyleAttributeName : paragraphStyle
        ]
        attributedText = NSMutableAttributedString(string: title, attributes: attributes)

        contentHorizontalAlignment = .center
        self.titleLabel?.textAlignment = .center
        self.setAttributedTitle(attributedText, for: state)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let size = super.sizeThatFits(size)
        return CGSize(width: max(44.0, size.width), height: 44.0)
    }
}
