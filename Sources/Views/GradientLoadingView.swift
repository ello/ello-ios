////
///  GradientLoadingView.swift
//

import QuartzCore
import PINRemoteImage


class GradientLoadingView: UIView {
    struct Size {
        static let size = CGSize(width: 60, height: 60)
    }

    var isLogoAnimating: Bool { return _isAnimating }
    private var _isAnimating = false
    private let loadingLayer = LoadingGradientLayer()

    override var intrinsicContentSize: CGSize {
        return Size.size
    }

    convenience init() {
        self.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        privateInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        privateInit()
    }

    private func privateInit() {
        layer.addSublayer(loadingLayer)
        contentMode = .scaleAspectFit
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil && _isAnimating {
            startAnimating()
        }
    }

    func startAnimating() {
        _isAnimating = true

        loadingLayer.startAnimating()
    }

    func stopAnimating() {
        _isAnimating = false

        loadingLayer.stopAnimating()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let loadingSize = intrinsicContentSize
        loadingLayer.cornerRadius = min(loadingSize.height, loadingSize.width) / 2
        loadingLayer.frame.size = loadingSize
        loadingLayer.frame.center = bounds.center
    }
}
