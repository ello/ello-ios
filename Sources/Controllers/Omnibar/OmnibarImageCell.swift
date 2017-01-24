////
///  OmnibarImageCell.swift
//

class OmnibarImageCell: UITableViewCell {
    static let reuseIdentifier = "OmnibarImageCell"

    struct Size {
        static let bottomMargin = CGFloat(15)
        static let editingMargins = UIEdgeInsets(top: 7.5, left: 8, bottom: 7.5, right: 12)
        static let editingHeight = CGFloat(80)
    }

    let flImageView = FLAnimatedImageView()
    let buyButton = UIButton()
    var reordering = false
    var hasBuyButtonURL = false

    var omnibarImage: UIImage? {
        get { return flImageView.image }
        set { flImageView.image = newValue }
    }

    var omnibarAnimagedImage: FLAnimatedImage? {
        get { return flImageView.animatedImage }
        set { flImageView.animatedImage = newValue }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        arrange()
        self.style()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func style() {
        flImageView.clipsToBounds = true
        flImageView.contentMode = .scaleAspectFit
        buyButton.backgroundColor = .greenD1()
        buyButton.adjustsImageWhenDisabled = false
        buyButton.adjustsImageWhenHighlighted = false
        buyButton.setImage(.buyButton, imageStyle: .normal, for: .normal)
        buyButton.setImage(.buyButton, imageStyle: .normal, for: .disabled)
        buyButton.layer.cornerRadius = buyButton.frame.size.width / 2
        buyButton.isHidden = true
        buyButton.isEnabled = false
    }

    fileprivate func arrange() {
        buyButton.frame.size = CGSize(width: 35, height: 35)
        contentView.addSubview(flImageView)
        contentView.addSubview(buyButton)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let margins: UIEdgeInsets
        if reordering {
            margins = Size.editingMargins

            flImageView.contentMode = .scaleAspectFill
            buyButton.isHidden = true
        }
        else {
            margins = UIEdgeInsets(all: 0)

            flImageView.contentMode = .scaleAspectFit
            buyButton.isHidden = !hasBuyButtonURL
        }

        let innerFrame = contentView.bounds
        let intrinsicSize = flImageView.intrinsicContentSize
        flImageView.frame = CGRect(
            origin: .zero,
            size: CGSize(
                width: min(intrinsicSize.width, innerFrame.size.width),
                height: min(intrinsicSize.height, innerFrame.size.height)
        )).inset(margins)

        buyButton.frame.origin = CGPoint(
            x: flImageView.frame.maxX - 10 - buyButton.frame.size.width,
            y: 10
            )
    }

    class func heightForImage(_ image: UIImage, tableWidth: CGFloat, editing: Bool) -> CGFloat {
        if editing {
            return Size.editingHeight
        }

        let cellWidth = tableWidth
        let imageWidth = max(image.size.width, 1)
        var height = image.size.height * cellWidth / imageWidth
        if editing {
            height += Size.bottomMargin
        }
        return min(height, image.size.height)
    }

}
