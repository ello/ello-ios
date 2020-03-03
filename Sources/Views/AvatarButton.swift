////
///  AvatarButton.swift
//

class AvatarButton: Button {
    struct Size {
        static let normalSize = CGSize(width: 40, height: 40)
        static let smallSize = CGSize(width: 30, height: 30)
    }
    // for specs; ensure the correct URL is assigned
    var imageURL: URL?

    override func style() {
        clipsToBounds = false
    }

    func setUserAvatar(_ image: UIImage) {
        imageURL = nil
        pin_cancelImageDownload()
        setImage(image, for: .normal)
    }

    func setUserAvatarURL(_ url: URL?) {
        imageURL = url
        setDefaultImage()

        guard let url = url else { return }

        pin_setImage(from: url) { result in
            guard result.image != nil else { return }
            self.invalidateIntrinsicContentSize()

            if result.resultType != .memoryCache {
                self.alpha = 0
                elloAnimate {
                    self.alpha = 1
                }
            }
            else {
                self.alpha = 1
            }
        }
    }

    func setDefaultImage() {
        pin_cancelImageDownload()
        setImage(nil, for: .normal)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let imageView = self.imageView {
            imageView.layer.cornerRadius = imageView.bounds.size.height / CGFloat(2)
        }
    }

}
