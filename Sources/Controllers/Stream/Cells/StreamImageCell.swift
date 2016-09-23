////
///  StreamImageCell.swift
//

import FLAnimatedImage
import PINRemoteImage
import Alamofire

public class StreamImageCell: StreamRegionableCell {
    static let reuseIdentifier = "StreamImageCell"

    // this little hack prevents constraints from breaking on initial load
    override public var bounds: CGRect {
        didSet {
          contentView.frame = bounds
        }
    }

    public struct Size {
        static let bottomMargin: CGFloat = 10
        static let singleColumnFailWidth: CGFloat = 140
        static let singleColumnFailHeight: CGFloat = 160
        static let multiColumnFailWidth: CGFloat = 70
        static let multiColumnFailHeight: CGFloat = 80
        static let multiColumnBuyButtonWidth: CGFloat = 30
        static let singleColumnBuyButtonWidth: CGFloat = 40
    }

    @IBOutlet public weak var imageView: FLAnimatedImageView!
    @IBOutlet public weak var imageButton: UIView!
    @IBOutlet public weak var buyButton: UIButton?
    @IBOutlet public weak var buyButtonGreen: UIView?
    @IBOutlet public weak var buyButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet public weak var circle: PulsingCircle!
    @IBOutlet public weak var failImage: UIImageView!
    @IBOutlet public weak var failBackgroundView: UIView!
    @IBOutlet public weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var failWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var failHeightConstraint: NSLayoutConstraint!

    // not used in StreamEmbedCell
    @IBOutlet public weak var largeImagePlayButton: UIImageView?
    @IBOutlet public weak var imageRightConstraint: NSLayoutConstraint!

    weak var streamImageCellDelegate: StreamImageCellDelegate?
    weak var streamEditingDelegate: StreamEditingDelegate?
    public var isGif = false
    public typealias OnHeightMismatch = (CGFloat) -> Void
    public var onHeightMismatch: OnHeightMismatch?
    public var tallEnoughForFailToShow = true
    public var presentedImageUrl: NSURL?
    public var buyButtonURL: NSURL? {
        didSet {
            let hidden = (buyButtonURL == nil)
            buyButton?.hidden = hidden
            buyButtonGreen?.hidden = hidden
        }
    }
    var serverProvidedAspectRatio: CGFloat?
    public var isLargeImage: Bool {
        get { return !(largeImagePlayButton?.hidden ?? true) }
        set {
            largeImagePlayButton?.image = InterfaceImage.VideoPlay.normalImage
            largeImagePlayButton?.hidden = !newValue
        }
    }
    public var isGridView: Bool = false {
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

    public enum StreamImageMargin {
        case Post
        case Comment
        case Repost
    }
    public var margin: CGFloat {
        switch marginType {
        case .Post:
            return 0
        case .Comment:
            return StreamTextCellPresenter.commentMargin
        case .Repost:
            return StreamTextCellPresenter.repostMargin
        }
    }
    public var marginType: StreamImageMargin = .Post {
        didSet {
            leadingConstraint.constant = margin
            if marginType == .Repost {
                showBorder()
            }
            else {
                hideBorder()
            }
        }
    }

    private var imageSize: CGSize?
    private var aspectRatio: CGFloat? {
        guard let imageSize = imageSize else { return nil }
        return imageSize.width / imageSize.height
    }

    var calculatedHeight: CGFloat? {
        guard let aspectRatio = aspectRatio else {
            return nil
        }
        return frame.width / aspectRatio
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        if let playButton = largeImagePlayButton {
            playButton.image = InterfaceImage.VideoPlay.normalImage
        }
        if let buyButton = buyButton, buyButtonGreen = buyButtonGreen {
            buyButton.hidden = true
            buyButtonGreen.hidden = true
            buyButton.setTitle(nil, forState: .Normal)
            buyButton.setImage(.BuyButton, imageStyle: .Normal, forState: .Normal)
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
        singleTapGesture.requireGestureRecognizerToFail(doubleTapGesture)
        imageButton.addGestureRecognizer(singleTapGesture)

        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.addTarget(self, action: #selector(imageLongPressed(_:)))
        imageButton.addGestureRecognizer(longPressGesture)
    }

    public func setImageURL(url: NSURL) {
        imageView.image = nil
        imageView.alpha = 0
        circle.pulse()
        failImage.hidden = true
        failImage.alpha = 0
        imageView.backgroundColor = UIColor.whiteColor()
        loadImage(url)
    }

    public func setImage(image: UIImage) {
        imageView.pin_cancelImageDownload()
        imageView.image = image
        imageView.alpha = 1
        failImage.hidden = true
        failImage.alpha = 0
        imageView.backgroundColor = UIColor.whiteColor()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        if let aspectRatio = aspectRatio, imageSize = imageSize {
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

    private func loadImage(url: NSURL) {
        guard url.scheme != "" else {
            if let urlWithScheme = NSURL(string: "https:\(url.absoluteString)") {
                loadImage(urlWithScheme)
            }
            return
        }
        self.imageView.pin_setImageFromURL(url) { result in
            let success = result.image != nil || result.animatedImage != nil
            let isAnimated = result.animatedImage != nil
            if success {
                let imageSize = isAnimated ? result.animatedImage.size : result.image.size
                self.imageSize = imageSize

                if self.serverProvidedAspectRatio == nil {
                    postNotification(StreamNotification.AnimateCellHeightNotification, value: self)
                }

                if result.resultType != .MemoryCache {
                    self.imageView.alpha = 0
                    UIView.animateWithDuration(0.3,
                        delay:0.0,
                        options:UIViewAnimationOptions.CurveLinear,
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

    private func imageLoadFailed() {
        buyButton?.hidden = true
        buyButtonGreen?.hidden = true
        failImage.hidden = false
        failBackgroundView.hidden = false
        circle.stopPulse()
        imageSize = nil
        largeImagePlayButton?.hidden = true
        nextTick { postNotification(StreamNotification.AnimateCellHeightNotification, value: self) }
        UIView.animateWithDuration(0.15) {
            self.failImage.alpha = 1.0
            self.imageView.backgroundColor = UIColor.greyF1()
            self.failBackgroundView.backgroundColor = UIColor.greyF1()
            self.imageView.alpha = 1.0
            self.failBackgroundView.alpha = 1.0
        }
    }

    override public func prepareForReuse() {
        super.prepareForReuse()

        marginType = .Post
        imageButton.userInteractionEnabled = true
        onHeightMismatch = nil
        imageView.image = nil
        imageView.animatedImage = nil
        imageView.pin_cancelImageDownload()
        imageRightConstraint?.constant = 0
        buyButton?.hidden = true
        buyButtonGreen?.hidden = true

        hideBorder()
        isGif = false
        presentedImageUrl = nil
        isLargeImage = false
        failImage.hidden = true
        failImage.alpha = 0
        failBackgroundView.hidden = true
        failBackgroundView.alpha = 0
    }

    @IBAction func imageTapped() {
        streamImageCellDelegate?.imageTapped(self.imageView, cell: self)
    }

    @IBAction func buyButtonTapped() {
        guard let buyButtonURL = buyButtonURL else {
            return
        }
        Tracker.sharedTracker.buyButtonLinkVisited(buyButtonURL.URLString)
        postNotification(ExternalWebNotification, value: buyButtonURL.URLString)
    }

    @IBAction func imageDoubleTapped(gesture: UIGestureRecognizer) {
        let location = gesture.locationInView(nil)
        streamEditingDelegate?.cellDoubleTapped(self, location: location)
    }

    @IBAction func imageLongPressed(gesture: UIGestureRecognizer) {
        if gesture.state == .Began {
            streamEditingDelegate?.cellLongPressed(self)
        }
    }
}
