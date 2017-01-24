////
///  BlackBar.swift
//

class BlackBar: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        backgroundColor = .black
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 20)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.frame.size.height = 20
    }

}
