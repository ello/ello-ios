////
///  ElloLogoView.swift
//

import QuartzCore
import PINRemoteImage


class ElloLogoView: UIImageView {
    struct Size {
        static let size = CGSize(width: 60, height: 60)
    }

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
        contentMode = .scaleAspectFit
        image = InterfaceImage.elloLogo.normalImage
    }
}
