////
///  PulsingCircle.swift
//

import QuartzCore

public class PulsingCircle: UIView {
    struct Size {
        static let size: CGFloat = 60
    }

    private lazy var pulser: UIView = self.createPulser()

    // moved into a separate function to save compile time
    private func createPulser() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Size.size, height: Size.size))
        view.center = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
        view.autoresizingMask = [.FlexibleTopMargin, .FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleRightMargin]
        view.layer.cornerRadius = Size.size / 2
        view.backgroundColor = UIColor.greyA()
        view.clipsToBounds = true
        self.addSubview(view)
        return view
    }

    private var isPulsing: Bool = false
    private var shouldReanimate: Bool = false

    override public func willMoveToWindow(newWindow: UIWindow?) {
        super.willMoveToWindow(newWindow)
        if isPulsing && newWindow == nil {
            shouldReanimate = true
        }
    }

    override public func didMoveToWindow() {
        super.didMoveToWindow()
        self.userInteractionEnabled = false
        if window != nil && shouldReanimate {
            shouldReanimate = false
            pulse()
        }
    }

    func stopPulse(completion: ((Bool) -> Void)? = nil) {
        shouldReanimate = false
        isPulsing = false
        UIView.animateWithDuration(0.65,
            delay: 0.0,
            options: .CurveEaseOut,
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

    private func keepPulsing() {
        self.pulser.alpha = 1
        UIView.animateWithDuration(0.65,
            delay: 0.0,
            options: .CurveEaseOut,
            animations: {
                self.pulser.transform = CGAffineTransformMakeScale(0.8, 0.8)
            },
            completion: { done in
                if self.isPulsing {
                    UIView.animateWithDuration(0.65,
                        delay: 0.0,
                        options: .CurveEaseOut,
                        animations: {
                            self.pulser.transform = CGAffineTransformMakeScale(1.0, 1.0)
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
