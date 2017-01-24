////
///  StreamImageCell.swift
//

import FLAnimatedImage
import PINRemoteImage
import Alamofire

class StreamImageCell: StreamRegionableCell {
    static let reuseIdentifier = "StreamImageCell"

    // this little hack prevents constraints from breaking on initial load
    override var bounds: CGRect {
        didSet {
          contentView.frame = bounds
        }
    }

    struct Size {
        static let bottomMargin: CGFloat = 10
        static let singleColumnFailWidth: CGFloat = 140
        static let singleColumnFailHeight: CGFloat = 160
        static let multiColumnFailWidth: CGFloat = 70
        static let multiColumnFailHeight: CGFloat = 80
        static let multiColumnBuyButtonWidth: CGFloat = 30
        static let singleColumnBuyButtonWidth: CGFloat = 40
    }

    @IBOutlet weak var imageView: FLAnimatedImageView!
    @IBOutlet weak var imageButton: UIView!
    @IBOutlet weak var buyButton: UIButton?
    @IBOutlet weak var buyButtonGreen: UIView?
    @IBOutlet weak var buyButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var circle: PulsingCircle!
    @IBOutlet weak var failImage: UIImageView!
    @IBOutlet weak var failBackgroundView: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var failWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var failHeightConstraint: NSLayoutConstraint!

    // not used in StreamEmbedCell
    @IBOutlet weak var largeImagePlayButton: UIImageView?
    @IBOutlet weak var imageRightConstraint: NSLayoutConstraint!

    weak var streamImageCellDelegate: StreamImageCellDelegate?
    weak var streamEditingDelegate: StreamEditingDelegate?
    var isGif = false
    var onHeightMismatch: OnHeightMismatch?
    var tallEnoughForFailToShow = true
    var presentedImageUrl: URL?
    var buyButtonURL: URL? {
        didSet {
            let hidden = (buyButtonURL == nil)
            buyButton?.isHidden = hidden
            buyButtonGreen?.isHidden = hidden
        }
    }
    var serverProvidedAspectRatio: CGFloat?
    var isLargeImage: Bool {
        get { return !(largeImagePlayButton?.isHidden ?? true) }
        set {
            largeImagePlayButton?.image = InterfaceImage.videoPlay.normalImage
            largeImagePlayButton?.isHidden = !newValue
        }
    }
    var isGridView: Bool = false {
        didSet {
            if isGridView {
                buyButtonWidthConstraint.constant = Size.multiColumnBuyButtonWidth
                failWidthConstraint.constant = Size.multiColumnFailWidth
                failHeightConstraint.constant = Size.multiColumnFailHeight
            }
            else {
                buyButtonWidthConstraint.constant = Size.singleColumnBuyButtonWidth
                failWidthConstraint.constant = Size.singleColumnFailWidth
                failHeightConstraint.constant = Size.singleColumnFailHeight
            }
        }
    }

    enum StreamImageMargin {
        case post
        case comment
        case repost
    }
    var margin: CGFloat {
        switch marginType {
        case .post:
            return 0
        case .comment:
            return StreamTextCellPresenter.commentMargin
        case .repost:
            return StreamTextCellPresenter.repostMargin
        }
    }
    var marginType: StreamImageMargin = .post {
        didSet {
            leadingConstraint.constant = margin
            if marginType == .repost {
                showBorder()
            }
            else {
                hideBorder()
            }
        }
    }

    fileprivate var imageSize: CGSize?
    fileprivate var aspectRatio: CGFloat? {
        guard let imageSize = imageSize else { return nil }
        return imageSize.width / imageSize.height
    }

    var calculatedHeight: CGFloat? {
        guard let aspectRatio = aspectRatio else {
            return nil
        }
        return frame.width / aspectRatio
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        if let playButton = largeImagePlayButton {
            playButton.image = InterfaceImage.videoPlay.normalImage
        }
        if let buyButton = buyButton, let buyButtonGreen = buyButtonGreen {
            buyButton.isHidden = true
            buyButtonGreen.isHidden = true
            buyButton.setTitle(nil, for: .normal)
            buyButton.setImage(.buyButton, imageStyle: .normal, for: .normal)
            buyButtonGreen.backgroundColor = .greenD1()
            buyButtonGreen.setNeedsLayout()
            buyButtonGreen.layoutIfNeeded()
            buyButtonGreen.layer.cornerRadius = buyButtonGreen.frame.size.width / 2

        }

        let doubleTapGesture = UITapGestureRecognizer()
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.addTarget(self, action: #selector(imageDoubleTapped(_:)))
        imageButton.addGestureRecognizer(doubleTapGesture)

        let singleTapGesture = UITapGestureRecognizer()
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.addTarget(self, action: #selector(imageTapped))
        singleTapGesture.require(toFail: doubleTapGesture)
        imageButton.addGestureRecognizer(singleTapGesture)

        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.addTarget(self, action: #selector(imageLongPressed(_:)))
        imageButton.addGestureRecognizer(longPressGesture)
    }

    func setImageURL(_ url: URL) {
        imageView.image = nil
        imageView.alpha = 0
        circle.pulse()
        failImage.isHidden = true
        failImage.alpha = 0
        imageView.backgroundColor = UIColor.white
        loadImage(url)
    }

    func setImage(_ image: UIImage) {
        imageView.pin_cancelImageDownload()
        imageView.image = image
        imageView.alpha = 1
        failImage.isHidden = true
        failImage.alpha = 0
        imageView.backgroundColor = UIColor.white
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let aspectRatio = aspectRatio, let imageSize = imageSize {
            let width = min(imageSize.width, self.frame.width)
            let actualHeight: CGFloat = ceil(width / aspectRatio) + Size.bottomMargin
            if actualHeight != frame.height {
                self.onHeightMismatch?(actualHeight)
            }
        }

        if let buyButtonGreen = buyButtonGreen {
            buyButtonGreen.setNeedsLayout()
            buyButtonGreen.layoutIfNeeded()
            buyButtonGreen.layer.cornerRadius = buyButtonGreen.frame.size.width / 2
        }
    }

    fileprivate func loadImage(_ url: URL) {
        guard url.scheme?.isEmpty == false else {
            if let urlWithScheme = URL(string: "https:\(url.absoluteString)") {
                loadImage(urlWithScheme)
            }
            return
        }
        self.imageView.pin_setImage(from: url) { result in
            let success = result?.image != nil || result?.animatedImage != nil
            let isAnimated = result?.animatedImage != nil
            if success {
                let imageSize = isAnimated ? result?.animatedImage.size : result?.image.size
                self.imageSize = imageSize

                if self.serverProvidedAspectRatio == nil {
                    postNotification(StreamNotification.AnimateCellHeightNotification, value: self)
                }

                if result?.resultType != .memoryCache {
                    self.imageView.alpha = 0
                    UIView.animate(withDuration: 0.3,
                        delay:0.0,
                        options:UIViewAnimationOptions.curveLinear,
                        animations: {
                            self.imageView.alpha = 1.0
                        }, completion: { _ in
                            self.circle.stopPulse()
                        })
                }
                else {
                    self.imageView.alpha = 1.0
                    self.circle.stopPulse()
                }

                self.layoutIfNeeded()
            }
            else {
                self.imageLoadFailed()
            }
        }
    }

    fileprivate func imageLoadFailed() {
        buyButton?.isHidden = true
        buyButtonGreen?.isHidden = true
        failImage.isHidden = false
        failBackgroundView.isHidden = false
        circle.stopPulse()
        imageSize = nil
        largeImagePlayButton?.isHidden = true
        nextTick { postNotification(StreamNotification.AnimateCellHeightNotification, value: self) }
        UIView.animate(withDuration: 0.15, animations: {
            self.failImage.alpha = 1.0
            self.imageView.backgroundColor = UIColor.greyF1()
            self.failBackgroundView.backgroundColor = UIColor.greyF1()
            self.imageView.alpha = 1.0
            self.failBackgroundView.alpha = 1.0
        })
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        marginType = .post
        imageButton.isUserInteractionEnabled = true
        onHeightMismatch = nil
        imageView.image = nil
        imageView.animatedImage = nil
        imageView.pin_cancelImageDownload()
        imageRightConstraint?.constant = 0
        buyButton?.isHidden = true
        buyButtonGreen?.isHidden = true

        hideBorder()
        isGif = false
        presentedImageUrl = nil
        isLargeImage = false
        failImage.isHidden = true
        failImage.alpha = 0
        failBackgroundView.isHidden = true
        failBackgroundView.alpha = 0
    }

    @IBAction func imageTapped() {
        streamImageCellDelegate?.imageTapped(imageView: self.imageView, cell: self)
    }

    @IBAction func buyButtonTapped() {
        guard let buyButtonURL = buyButtonURL else {
            return
        }
        Tracker.shared.buyButtonLinkVisited(buyButtonURL.absoluteString)
        postNotification(ExternalWebNotification, value: buyButtonURL.absoluteString)
    }

    @IBAction func imageDoubleTapped(_ gesture: UIGestureRecognizer) {
        let location = gesture.location(in: nil)
        streamEditingDelegate?.cellDoubleTapped(cell: self, location: location)
    }

    @IBAction func imageLongPressed(_ gesture: UIGestureRecognizer) {
        if gesture.state == .began {
            streamEditingDelegate?.cellLongPressed(cell: self)
        }
    }
}
