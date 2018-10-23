////
///  ProfileHeaderLocationCell.swift
//

class ProfileHeaderLocationCell: ProfileHeaderCell {
    static let reuseIdentifier = "ProfileHeaderLocationCell"

    struct Size {
        static let height: CGFloat = 48
        static let markerHeight: CGFloat = 14
        static let leadingMargin: CGFloat = 12
        static let markerLocationMargin: CGFloat = 6
    }

    var location: String {
        get { return locationLabel.text ?? "" }
        set {
            locationLabel.text = newValue
            let totalHeight: CGFloat
            if newValue.isEmpty {
                totalHeight = 0
            }
            else {
                totalHeight = Size.height
            }
            if totalHeight != frame.size.height {
                heightMismatchOccurred(totalHeight)
            }
        }
    }

    private let locationLabel = UILabel()
    private let markerImageView = UIImageView(image: InterfaceImage.marker.normalImage)

    override func style() {
        clipsToBounds = true
        backgroundColor = .white
        locationLabel.font = .defaultFont()
        locationLabel.textColor = .greyA
    }

    override func arrange() {
        contentView.addSubview(locationLabel)
        contentView.addSubview(markerImageView)

        markerImageView.snp.makeConstraints { make in
            make.width.height.equalTo(Size.markerHeight)
            make.centerY.equalTo(contentView).offset(-1)
            make.leading.equalTo(contentView).inset(Size.leadingMargin)
        }

        locationLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(markerImageView.snp.trailing).offset(Size.markerLocationMargin)
        }
    }
}

extension ProfileHeaderLocationCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        location = ""
    }
}
