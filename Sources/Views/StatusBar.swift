////
///  StatusBar.swift
//

class StatusBar: View {
    struct Size {
        static let height: CGFloat = calculateHeight()

        static private func calculateHeight() -> CGFloat {
            return Globals.statusBarHeight
        }
    }

    override func style() {
        autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        backgroundColor = .black
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: Size.height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.frame.size.height = Size.height
    }

}
