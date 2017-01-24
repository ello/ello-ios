////
///  CreateCommentBackgroundView.swift
//

class CreateCommentBackgroundView: UIView {

    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = UIColor.clear
    }

    override func draw(_ rect: CGRect) {
        let color = UIColor.black
        let margin: CGFloat = 10
        let midY = self.frame.height / CGFloat(2)

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        let radius: CGFloat = 5
        let π = CGFloat(M_PI)
        let corners = (
            tl: CGPoint(x: margin + radius, y: radius),
            tr: CGPoint(x: bounds.width - radius, y: radius),
            bl: CGPoint(x: margin + radius, y: bounds.height - radius),
            br: CGPoint(x: bounds.width - radius, y: bounds.height - radius)
        )

        bezierPath.move(to: CGPoint(x: 0, y: midY))
        bezierPath.addLine(to: CGPoint(x: margin, y: midY - margin))
        bezierPath.addArc(withCenter: corners.tl, radius: radius, startAngle: -π, endAngle: -π / 2, clockwise: true)
        bezierPath.addArc(withCenter: corners.tr, radius: radius, startAngle: -π / 2, endAngle: 0, clockwise: true)
        bezierPath.addArc(withCenter: corners.br, radius: radius, startAngle: 0, endAngle: π / 2, clockwise: true)
        bezierPath.addArc(withCenter: corners.bl, radius: radius, startAngle: π / 2, endAngle: π, clockwise: true)
        bezierPath.addLine(to: CGPoint(x: margin, y: midY + margin))
        bezierPath.close()
        color.setFill()
        bezierPath.fill()
    }
}
