////
///  PersistentBackButton.swift
//

class PersistentBackButton: Button {
    struct Size {
        static let size = CGSize(width: 30, height: 30)
    }

    override var intrinsicContentSize: CGSize {
        return Size.size
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(frame.width, frame.height) / 2
    }

    override func style() {
        super.style()

        backgroundColor = .white
        setImages(.backChevron)
        layer.masksToBounds = true
        contentEdgeInsets = UIEdgeInsets(right: 2)
    }
}
