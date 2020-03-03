////
///  ElloPullToRefreshView.swift
//

import SSPullToRefresh
import QuartzCore

class ElloPullToRefreshView: UIView, SSPullToRefreshContentView {

    lazy var elloLogo: GradientLoadingView = {
        let logo = GradientLoadingView()
        logo.alpha = 0
        logo.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return logo
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedInit()
    }

    private func sharedInit() {
        self.addSubview(elloLogo)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        elloLogo.center = CGPoint(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
    }

    // MARK: SSPullToRefreshContentView

    func setState(_ state: SSPullToRefreshViewState, with view: SSPullToRefreshView!) {
        switch state {
        case .ready:
            break
        case .normal:
            elloLogo.alpha = 0
        case .loading:
            elloLogo.startAnimating()
        case .closing:
            elloLogo.stopAnimating()
            elloAnimate {
                self.elloLogo.alpha = 0
            }
        }
    }

    func setPullProgress(_ pullProgress: CGFloat) {
        let alpha: CGFloat = clip(
            map(pullProgress, fromInterval: (0.25, 0.8), toInterval: (0, 1)),
            min: 0,
            max: 1
        )
        elloLogo.alpha = alpha
    }

}
