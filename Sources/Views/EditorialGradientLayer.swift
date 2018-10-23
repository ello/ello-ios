////
///  EditorialGradientLayer.swift
//

class EditorialGradientLayer: CAGradientLayer {
    override init(layer: Any) {
        super.init(layer: layer)
    }

    override init() {
        super.init()

        locations = [0, 1]
        colors = [
            UIColor(hex: 0x000000, alpha: 0.8).cgColor,
            UIColor(hex: 0x000000, alpha: 0.4).cgColor,
        ]
        startPoint = CGPoint(x: 0.5, y: 1)
        endPoint = CGPoint(x: 0.5, y: 0.43)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
