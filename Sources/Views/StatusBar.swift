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
        backgroundColor = .black
    }

    override func arrange() {
        autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: Size.height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.frame.size.height = Size.height
    }

}
