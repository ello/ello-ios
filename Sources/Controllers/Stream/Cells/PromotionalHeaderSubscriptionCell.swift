////
///  PromotionalHeaderSubscriptionCell.swift
//

import SnapKit
import PINRemoteImage

class PromotionalHeaderSubscriptionCell: CollectionViewCell {
    static let reuseIdentifier = "PromotionalHeaderSubscriptionCell"
    struct Size {
        static let labelInsets = UIEdgeInsets(top: 1)
        static let height: CGFloat = 85
        static let subscribeIconSpacing: CGFloat = 10
    }

    private let bg = UIView()
    private let label = StyledLabel(style: .white)
    private let subscribedIcon = UIImageView()

    var isSubscribed: Bool {
        get { return isSelected }
        set { isSelected = newValue }
    }

    override var isSelected: Bool {
        didSet {
            bg.backgroundColor = isSubscribed ? .greyA : .greenD1
            subscribedIcon.isHidden = isSubscribed

            if isSubscribed {
                label.text = InterfaceString.Discover.Subscribed
            }
            else {
                label.text = InterfaceString.Discover.Subscribe
            }
        }
    }

    override func style() {
        subscribedIcon.setInterfaceImage(.circleCheckLarge, style: .white)
    }

    override func arrange() {
        contentView.addSubview(bg)
        contentView.addSubview(label)
        contentView.addSubview(subscribedIcon)

        bg.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(Size.labelInsets)
        }

        label.snp.makeConstraints { make in
            make.center.equalTo(bg)
        }

        subscribedIcon.snp.makeConstraints { make in
            make.trailing.equalTo(label.snp.leading).offset(-Size.subscribeIconSpacing)
            make.centerY.equalTo(label)
        }
    }
}
