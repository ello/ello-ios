////
///  AvatarButton.swift
//

class AvatarButton: UIButton {
    // for specs; ensure the correct URL is assigned
    var imageURL: URL?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
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

            if result.resultType != .memoryCache {
                self.alpha = 0
                elloAnimate {
                    self.alpha = 0
                }
            }
            else {
                self.alpha = 1.0
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
