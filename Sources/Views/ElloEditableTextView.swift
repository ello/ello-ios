////
///  ElloEditableTextView.swift
//

class ElloEditableTextView: UITextView {
    required override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        sharedSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedSetup()
    }

    func sharedSetup() {
        backgroundColor = UIColor.greyE5()
        font = UIFont.defaultFont()
        textColor = UIColor.black
        contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        scrollsToTop = false
        setNeedsDisplay()
    }
}
