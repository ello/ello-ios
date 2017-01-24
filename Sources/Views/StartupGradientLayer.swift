////
///  StartupGradientLayer.swift
//

class StartupGradientLayer: CAGradientLayer {
    override init(layer: Any) {
        super.init(layer: layer)
    }

    override init() {
        super.init()

        locations = [0, 1]
        colors = [
            UIColor(hex: 0x673f00).cgColor,
            UIColor(hex: 0x67191f).cgColor,
        ]
        startPoint = CGPoint(x: 1, y: 1)
        endPoint = CGPoint(x: 0, y: 0)
        addGradientAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func addGradientAnimation() {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "colors"
        animation.values = [
            [UIColor(hex: 0x673f00).cgColor, UIColor(hex: 0x67191f).cgColor],
            [UIColor(hex: 0x67191f).cgColor, UIColor(hex: 0x67325c).cgColor],
            [UIColor(hex: 0x67325c).cgColor, UIColor(hex: 0x2b3967).cgColor],
            [UIColor(hex: 0x2b3967).cgColor, UIColor(hex: 0x2a624d).cgColor],
            [UIColor(hex: 0x2a624d).cgColor, UIColor(hex: 0x673f00).cgColor],
            [UIColor(hex: 0x2b3967).cgColor, UIColor(hex: 0x2a624d).cgColor],
            [UIColor(hex: 0x67325c).cgColor, UIColor(hex: 0x2b3967).cgColor],
            [UIColor(hex: 0x67191f).cgColor, UIColor(hex: 0x67325c).cgColor],
            [UIColor(hex: 0x673f00).cgColor, UIColor(hex: 0x67191f).cgColor],
        ]
        animation.keyTimes = [
            0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1,
        ]
        animation.duration = 30
        animation.repeatCount = Float.infinity
        add(animation, forKey: "comments")
    }

}
