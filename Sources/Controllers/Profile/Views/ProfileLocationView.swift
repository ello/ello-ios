////
///  ProfileLocationView.swift
//

class ProfileLocationView: ProfileBaseView {
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
                onHeightMismatch?(totalHeight)
            }
        }
    }

    fileprivate let locationLabel = UILabel()
    fileprivate let markerImageView = UIImageView(image: InterfaceImage.marker.normalImage)

    fileprivate let grayLine = UIView()
    var grayLineVisible: Bool {
        get { return !grayLine.isHidden }
        set { grayLine.isHidden = !newValue }
    }

    var onHeightMismatch: OnHeightMismatch?
}

extension ProfileLocationView {

    override func style() {
        clipsToBounds = true
        backgroundColor = .white
        locationLabel.font = .defaultFont()
        locationLabel.textColor = .greyA()
        grayLine.backgroundColor = .greyE5()
    }

    override func arrange() {
        addSubview(grayLine)
        addSubview(locationLabel)
        addSubview(markerImageView)

        grayLine.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.equalTo(self)
            make.leading.trailing.equalTo(self).inset(ProfileBaseView.Size.grayInset)
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

    func prepareForReuse() {
        location = ""
    }
}

extension ProfileLocationView: ProfileViewProtocol {}
