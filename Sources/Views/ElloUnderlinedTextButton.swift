////
///  ElloUnderlinedTextButton.swift
//

class ElloUnderlinedTextButton: UIButton {

    required override init(frame: CGRect) {
        super.init(frame: frame)
        sharedSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedSetup()
    }

    fileprivate func sharedSetup() {
        self.backgroundColor = UIColor.clear
        let lineBreakMode = self.titleLabel?.lineBreakMode ?? .byWordWrapping
        if lineBreakMode != .byWordWrapping {
            self.titleLabel?.numberOfLines = 1
        }
        self.setTitleColor(UIColor.greyA(), for: .normal)
        self.titleLabel?.font = UIFont.defaultFont()

        if let title = self.titleLabel?.text {
            let attributedString = NSAttributedString(string: title, attributes: [
                NSFontAttributeName: UIFont.defaultFont(),
                NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject,
                ])
            self.setAttributedTitle(attributedString, for: .normal)
        }
    }
}
