////
///  OmnibarImageCell.swift
//

import PINRemoteImage


class OmnibarImageCell: TableViewCell {
    static let reuseIdentifier = "OmnibarImageCell"

    struct Size {
        static let bottomMargin = CGFloat(15)
        static let editingMargins = UIEdgeInsets(top: 7.5, left: 8, bottom: 7.5, right: 12)
        static let editingHeight = CGFloat(80)
    }

    let flImageView = PINAnimatedImageView()
    let buyButton = UIButton()
    var isReordering = false
    var hasBuyButtonURL = false

    var omnibarImage: UIImage? {
        get { return flImageView.image }
        set { flImageView.image = newValue }
    }

    var omnibarAnimagedImage: PINCachedAnimatedImage? {
        get { return flImageView.animatedImage }
        set { flImageView.animatedImage = newValue }
    }

    override func styleCell() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        flImageView.clipsToBounds = true
        flImageView.contentMode = .scaleAspectFit
        buyButton.backgroundColor = .greenD1
        buyButton.adjustsImageWhenDisabled = false
        buyButton.adjustsImageWhenHighlighted = false
        buyButton.setImage(.buyButton, imageStyle: .normal, for: .normal)
        buyButton.setImage(.buyButton, imageStyle: .normal, for: .disabled)
        buyButton.layer.masksToBounds = true
        buyButton.layer.cornerRadius = buyButton.frame.size.width / 2
        buyButton.isHidden = true
        buyButton.isEnabled = false
    }

    override func arrange() {
        buyButton.frame.size = CGSize(width: 35, height: 35)
        contentView.addSubview(flImageView)
        contentView.addSubview(buyButton)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let margins: UIEdgeInsets
        if isReordering {
            margins = Size.editingMargins

            flImageView.contentMode = .scaleAspectFill
            buyButton.isHidden = true
        }
        else {
            margins = UIEdgeInsets(all: 0)

            flImageView.contentMode = .scaleAspectFit
            buyButton.isVisible = hasBuyButtonURL
        }

        let innerFrame = contentView.bounds
        let intrinsicSize = flImageView.intrinsicContentSize
        flImageView.frame = CGRect(
            origin: .zero,
            size: CGSize(
                width: min(intrinsicSize.width, innerFrame.size.width),
                height: min(intrinsicSize.height, innerFrame.size.height)
            )
        ).inset(margins)

        buyButton.frame.origin = CGPoint(
            x: flImageView.frame.maxX - 10 - buyButton.frame.size.width,
            y: 10
        )
        buyButton.layer.cornerRadius = buyButton.frame.size.width / 2
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
