////
///  OmnibarImageDownloadCell.swift
//

class OmnibarImageDownloadCell: UITableViewCell {
    static let reuseIdentifier = "OmnibarImageDownloadCell"

    struct Size {
        static let height = CGFloat(100)
    }

    let logoView = PulsingCircle()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(logoView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        logoView.frame = contentView.bounds
    }

    override func didMoveToSuperview() {
        logoView.pulse()
    }

}
