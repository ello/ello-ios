////
///  DrawerCell.swift
//

import SnapKit


class DrawerCell: TableViewCell {
    static let reuseIdentifier = "DrawerCell"

    struct Size {
        static let height: CGFloat = 60
        static let spacerHeight: CGFloat = 20
        static let inset = UIEdgeInsets(sides: 15)
    }

    enum Style {
        case `default`
        case version
    }

    var isLineVisible: Bool {
        get { return line.isVisible }
        set { line.isVisible = newValue }
    }
    var title: String? {
        get { return label.text }
        set { label.text = newValue }
    }
    var logo: UIImage? {
        get { return logoView.image }
        set {
            logoView.image = newValue
            hasImageConstraint.set(isActivated: newValue != nil)
            noImageConstraint.set(isActivated: newValue == nil)
        }
    }
    var style: Style = .default { didSet { updateStyle() } }

    private let label = StyledLabel(style: .white)
    private let logoView = UIImageView()
    private let line = Line(color: .grey5)
    private var hasImageConstraint: Constraint!
    private var noImageConstraint: Constraint!

    override func styleCell() {
        backgroundColor = .grey6
        selectionStyle = .none
    }

    override func arrange() {
        contentView.addSubview(label)
        contentView.addSubview(logoView)
        contentView.addSubview(line)

        logoView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.centerY.equalTo(contentView)
            make.leading.equalTo(contentView).inset(Size.inset)
        }

        label.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            hasImageConstraint =
                make.leading.equalTo(logoView.snp.trailing).offset(Size.inset.left).constraint
            noImageConstraint = make.leading.equalTo(contentView).inset(Size.inset).constraint
        }

        line.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(contentView)
        }
    }

    private func updateStyle() {
        if style == .version {
            label.style = .smallGray
        }
        else {
            label.style = .white
        }
    }
}
