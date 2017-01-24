////
///  TwoLineButton.swift
//

class TwoLineButton: UIButton {

    var title: String = "" {
        didSet { updateText() }
    }

    var count: String = "" {
        didSet { updateText() }
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedSetup()
    }

    func sharedSetup() {
        titleLabel?.numberOfLines = 0
        backgroundColor = .clear
        contentHorizontalAlignment = .left
    }

    // MARK: Private

    fileprivate func attributes(_ color: UIColor, font: UIFont, underline: Bool = false) -> [String : AnyObject] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = .left

        return [
            NSFontAttributeName : font,
            NSForegroundColorAttributeName : color,
            NSParagraphStyleAttributeName : paragraphStyle,
            NSUnderlineStyleAttributeName : (underline ? NSUnderlineStyle.styleSingle.rawValue : NSUnderlineStyle.styleNone.rawValue) as AnyObject
        ]
    }

    fileprivate func updateText() {
        let countNormalAttributes = attributes(UIColor.black, font: UIFont.defaultBoldFont())
        let countSelectedAttributes = attributes(UIColor.greyA(), font: UIFont.defaultBoldFont())

        let titleNormalAttributes = attributes(UIColor.greyA(), font: UIFont.defaultFont(), underline: true)
        let titleSelectedAttributes = attributes(UIColor.greyE5(), font: UIFont.defaultFont(), underline: true)

        let attributedNormalCount = NSAttributedString(string: count + "\n", attributes: countNormalAttributes)
        let attributedSelectedCount = NSAttributedString(string: count + "\n", attributes: countSelectedAttributes)

        let attributedNormalTitle = NSAttributedString(string: title, attributes: titleNormalAttributes)
        let attributedSelectedTitle = NSAttributedString(string: title, attributes: titleSelectedAttributes)

        setAttributedTitle(attributedNormalCount + attributedNormalTitle, for: .normal)
        setAttributedTitle(attributedSelectedCount + attributedSelectedTitle, for: .highlighted)
        sizeToFit()
    }

}
