////
///  ElloLogoView.swift
//

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
        style()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
    }

    override func traitCollectionDidChange(_ prev: UITraitCollection?) {
        super.traitCollectionDidChange(prev)
        style()
    }

    private func style() {
        contentMode = .scaleAspectFit
        image = InterfaceImage.elloLogo.image(.normal)
    }
}
