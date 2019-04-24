////
///  OmnibarErrorCell.swift
//

class OmnibarErrorCell: UITableViewCell {
    static let reuseIdentifier = "OmnibarErrorCell"
    struct Size {
        static let height = CGFloat(75)
        static let margins = CGFloat(10)
    }

    private let label = StyledLabel(style: .error)

    var url: URL? {
        get { return nil }
        set {
            if let url = newValue {
                label.text = InterfaceString.Omnibar.LoadingImageError(url: url)
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        label.numberOfLines = 2
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        label.frame = contentView.bounds.inset(all: Size.margins)
        label.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        contentView.addSubview(label)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
