////
///  ElloPullToRefreshView.swift
//

import SSPullToRefresh
import QuartzCore

class ElloPullToRefreshView: UIView, SSPullToRefreshContentView {

    fileprivate var pullProgress: CGFloat = 0
    fileprivate var loading = false
    fileprivate let toValue = (360.0 * M_PI) / 180.0

    lazy var elloLogo: ElloLogoView = {
        let logo = ElloLogoView()
        logo.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        logo.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        return logo
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    fileprivate func sharedInit() {
        self.addSubview(elloLogo)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        elloLogo.center = CGPoint(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
    }

// MARK: SSPullToRefreshContentView

    func setState(_ state: SSPullToRefreshViewState, with view: SSPullToRefreshView!) {
        switch state {
        case .loading:
            loading = true
            elloLogo.animateLogo()
        case .closing:
            loading = false
            elloLogo.stopAnimatingLogo()
        default:
            loading = false
        }
    }

    func setPullProgress(_ pullProgress: CGFloat) {
        self.pullProgress = pullProgress
        if !loading {
            let progress = min(Double(self.pullProgress), 1.0)
            let rotation = interpolate(from: M_PI, to: M_PI * 2, at: progress)
            elloLogo.transform = CGAffineTransform( rotationAngle: CGFloat(rotation) )
            setNeedsDisplay()
        }
    }

// MARK: Private

}
