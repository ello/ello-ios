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
    private let line = Line()
    private var hasImageConstraint: Constraint!
    private var noImageConstraint: Constraint!

    override func styleCell() {
        backgroundColor = .grey6
        line.backgroundColor = .grey5
        selectionStyle = .none
    }

    override func arrange() {
        contentView.addSubview(label)
        contentView.addSubview(logoView)
        contentView.addSubview(line)

        contentView.snp.makeConstraints { make in
            make.height.equalTo(Size.height)
        }

        logoView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.centerY.equalTo(self)
            make.leading.equalTo(self).inset(Size.inset)
        }

        label.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            hasImageConstraint = make.leading.equalTo(logoView.snp.trailing).offset(Size.inset.left).constraint
            noImageConstraint = make.leading.equalTo(self).inset(Size.inset).constraint
        }

        line.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(self)
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
