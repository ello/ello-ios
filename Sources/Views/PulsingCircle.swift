////
///  PulsingCircle.swift
//

import QuartzCore

class PulsingCircle: UIView {
    struct Size {
        static let size: CGFloat = 60
    }

    fileprivate lazy var pulser: UIView = self.createPulser()

    // moved into a separate function to save compile time
    fileprivate func createPulser() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Size.size, height: Size.size))
        view.center = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
        view.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        view.layer.cornerRadius = Size.size / 2
        view.backgroundColor = UIColor.greyA()
        view.clipsToBounds = true
        self.addSubview(view)
        return view
    }

    fileprivate var isPulsing: Bool = false
    fileprivate var shouldReanimate: Bool = false

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if isPulsing && newWindow == nil {
            shouldReanimate = true
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.isUserInteractionEnabled = false
        if window != nil && shouldReanimate {
            shouldReanimate = false
            pulse()
        }
    }

    func stopPulse(_ completion: ((Bool) -> Void)? = nil) {
        shouldReanimate = false
        isPulsing = false
        UIView.animate(withDuration: 0.65,
            delay: 0.0,
            options: .curveEaseOut,
            animations: {
                self.pulser.alpha = 0
            },
            completion: completion
        )
    }

    func pulse() {
        self.pulser.alpha = 1
        self.pulser.center = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
        if !isPulsing {
            self.isPulsing = true
            self.keepPulsing()
        }
    }

    fileprivate func keepPulsing() {
        self.pulser.alpha = 1
        UIView.animate(withDuration: 0.65,
            delay: 0.0,
            options: .curveEaseOut,
            animations: {
                self.pulser.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            },
            completion: { done in
                if self.isPulsing {
                    UIView.animate(withDuration: 0.65,
                        delay: 0.0,
                        options: .curveEaseOut,
                        animations: {
                            self.pulser.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        },
                        completion: { finished in
                            if self.isPulsing {
                                self.keepPulsing()
                            }
                        })
                }
        })
    }
}
