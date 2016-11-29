////
///  ProfileLocationView.swift
//

public class ProfileLocationView: ProfileBaseView {
    public struct Size {
        static let height: CGFloat = 60
        static let markerHeight: CGFloat = 20
        static let leadingMargin: CGFloat = 15
        static let markerLocationMargin: CGFloat = 15
    }

    public var location: String {
        get { return locationLabel.text ?? "" }
        set { locationLabel.text = newValue }
    }

    private let locationLabel = UILabel()
    private let markerImageView = UIImageView(image: InterfaceImage.Marker.normalImage)

    private let grayLine = UIView()
    var grayLineVisible: Bool {
        get { return !grayLine.hidden }
        set { grayLine.hidden = !newValue }
    }
}

extension ProfileLocationView {

    override func style() {
        backgroundColor = .whiteColor()
        locationLabel.font = .defaultFont()
        locationLabel.textColor = .greyA()
        grayLine.backgroundColor = .greyE5()
    }

    override func arrange() {
        addSubview(grayLine)
        addSubview(locationLabel)
        addSubview(markerImageView)

        grayLine.snp_makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.equalTo(self)
            make.leading.trailing.equalTo(self).inset(ProfileBaseView.Size.grayInset)
        }

        markerImageView.snp_makeConstraints { make in
            make.width.height.equalTo(Size.markerHeight)
            make.centerY.equalTo(self)
            make.leading.equalTo(self).inset(Size.leadingMargin)
        }

        locationLabel.snp_makeConstraints { make in
            make.centerY.equalTo(self)
            make.leading.equalTo(markerImageView.snp_trailing).offset(Size.markerLocationMargin)
        }
    }

    public func prepareForReuse() {
        // nothing here yet
    }
}

extension ProfileLocationView: ProfileViewProtocol {}
