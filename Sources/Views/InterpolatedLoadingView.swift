////
///  InterpolatedLoadingView.swift
//

class InterpolatedLoadingView: UIView {
    var round = false {
        didSet { setNeedsLayout() }
    }
    fileprivate var animating = false

    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.animateIfPossible()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.animateIfPossible()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if round {
            layer.cornerRadius = min(frame.size.width, frame.size.height) / 2
        }
        else {
            layer.cornerRadius = 0
        }
    }

    fileprivate func animateIfPossible() {
        if !animating && window != nil && superview != nil {
            animate()
        }
        else {
            animating = false
        }
    }

    fileprivate func animate() {
        animating = true

        self.layer.removeAnimation(forKey: "interpolate")
        let rotate = CABasicAnimation(keyPath: "backgroundColor")
        rotate.fromValue = UIColor(hex: 0xDDDDDD).cgColor
        rotate.toValue = UIColor(hex: 0xC4C4C4).cgColor
        rotate.duration = 3
        if round {
            rotate.beginTime = 0.25
        }
        rotate.repeatCount = 1_000_000
        rotate.autoreverses = true
        self.layer.add(rotate, forKey: "interpolate")
    }

}
