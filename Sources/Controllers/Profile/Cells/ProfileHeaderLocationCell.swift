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
        static let grayInsets: CGFloat = 15
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

    private let grayLine = UIView()
    var grayLineVisible: Bool {
        get { return !grayLine.isHidden }
        set { grayLine.isVisible = newValue }
    }

    override func style() {
        clipsToBounds = true
        backgroundColor = .white
        locationLabel.font = .defaultFont()
        locationLabel.textColor = .greyA
        grayLine.backgroundColor = .greyE5
    }

    override func arrange() {
        addSubview(grayLine)
        addSubview(locationLabel)
        addSubview(markerImageView)

        grayLine.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.equalTo(self)
            make.leading.trailing.equalTo(self).inset(Size.grayInsets)
        }

        markerImageView.snp.makeConstraints { make in
            make.width.height.equalTo(Size.markerHeight)
            make.centerY.equalTo(self).offset(-1)
            make.leading.equalTo(self).inset(Size.leadingMargin)
        }

        locationLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self)
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
