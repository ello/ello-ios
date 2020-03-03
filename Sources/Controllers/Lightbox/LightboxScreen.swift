////
///  LightboxScreen.swift
//

import PINRemoteImage
import SnapKit


class LightboxScreen: Screen, LightboxScreenProtocol {
    struct Size {
        static let insets = calculateInsets()
        static let lilBits: CGFloat = 15
        static let toolbarGradientHeight: CGFloat = 60

        private static func calculateInsets() -> UIEdgeInsets {
            if Globals.isIphoneX {
                return UIEdgeInsets(
                    top: Globals.statusBarHeight,
                    left: 10,
                    bottom: Globals.bestBottomMargin,
                    right: 10
                )
            }
            return UIEdgeInsets(tops: 30, sides: 10)
        }
    }
    weak var delegate: LightboxScreenDelegate! {
        didSet { updateImages(updateToolbar: true) }
    }

    enum Delta: Int {
        case prev = -1
        case next = 1
    }

    private let imagesContainer = Container()
    let toolbar = PostToolbar()
    private let toolbarBlackBar = UIView()
    private let toolbarGradientLayer = LightboxScreen.generateGradientLayer()
    private var toolbarVisibleConstraint: Constraint!
    private var toolbarHiddenConstraint: Constraint!

    private var gestureDeltaX: CGFloat = 0
    private var scrollPanGesture: UIPanGestureRecognizer!
    private var imagePanGesture: UIPanGestureRecognizer!
    private var imageScaleGesture: UIPinchGestureRecognizer!
    private var zoomOutGesture: UITapGestureRecognizer!
    private var loveGesture: UITapGestureRecognizer!
    private var dismissGesture: UITapGestureRecognizer!

    private var isZoomed: Bool { return imageScale > 1 }
    private var imageScale: CGFloat = 1
    private var imageOffset: CGPoint = .zero
    private var tempOffset: CGPoint = .zero

    private var prevImageView = PINAnimatedImageView()
    private var prevURL: URL?

    private var currImageView = PINAnimatedImageView()
    private var currImageFrame: CGRect = .zero
    private var currURL: URL?
    private let currLoadingLayer = LoadingGradientLayer()

    private var nextImageView = PINAnimatedImageView()
    private var nextURL: URL?

    private var isLoadingMore: Bool { return nextPageView.isLogoAnimating }
    private let nextPageView = GradientLoadingView()
    private var nextPageViewWidth: CGFloat!
    private var minX: CGFloat!
    private var maxX: CGFloat!
    private var minAngle: CGFloat!
    private var maxAngle: CGFloat!

    override func setup() {
        prevImageView.alpha = 0.5
        currImageView.alpha = 1
        nextImageView.alpha = 0.5
        nextPageView.isHidden = true

        nextPageViewWidth = nextPageView.intrinsicContentSize.width
        minX = nextPageViewWidth * 3 / 4
        maxX = minX + nextPageViewWidth
        minAngle = .pi
        maxAngle = 2 * .pi
    }

    override func style() {
        toolbar.style = .dark
        toolbarBlackBar.backgroundColor = .black

        backgroundColor = .clear
        prevImageView.contentMode = .scaleAspectFit
        currImageView.contentMode = .scaleAspectFit
        nextImageView.contentMode = .scaleAspectFit
    }

    override func bindActions() {
        toolbar.postToolsDelegate = self

        scrollPanGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(scrollPanGestureMovement(gesture:))
        )
        imagesContainer.addGestureRecognizer(scrollPanGesture)

        imagePanGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(imagePanGestureMovement(gesture:))
        )
        imagePanGesture.isEnabled = false
        imagesContainer.addGestureRecognizer(imagePanGesture)

        imageScaleGesture = UIPinchGestureRecognizer(
            target: self,
            action: #selector(pinchGestureMovement(gesture:))
        )
        imagesContainer.addGestureRecognizer(imageScaleGesture)

        loveGesture = UITapGestureRecognizer()
        loveGesture.numberOfTouchesRequired = 1
        loveGesture.numberOfTapsRequired = 2
        loveGesture.addTarget(self, action: #selector(loveAction(gesture:)))
        loveGesture.isEnabled = true
        imagesContainer.addGestureRecognizer(loveGesture)

        zoomOutGesture = UITapGestureRecognizer()
        zoomOutGesture.numberOfTouchesRequired = 1
        zoomOutGesture.numberOfTapsRequired = 2
        zoomOutGesture.addTarget(self, action: #selector(zoomOutAction))
        zoomOutGesture.isEnabled = false
        imagesContainer.addGestureRecognizer(zoomOutGesture)

        dismissGesture = UITapGestureRecognizer()
        dismissGesture.numberOfTouchesRequired = 1
        dismissGesture.numberOfTapsRequired = 1
        dismissGesture.addTarget(self, action: #selector(dismissAction))
        dismissGesture.require(toFail: loveGesture)
        imagesContainer.addGestureRecognizer(dismissGesture)
    }

    override func arrange() {
        toolbarGradientLayer.zPosition = -1
        toolbar.layer.insertSublayer(toolbarGradientLayer, at: 0)
        addSubview(imagesContainer)
        addSubview(toolbar)
        addSubview(toolbarBlackBar)

        imagesContainer.addSubview(prevImageView)
        imagesContainer.addSubview(nextImageView)
        imagesContainer.addSubview(currImageView)
        imagesContainer.addSubview(nextPageView)

        let loadingSize = StreamPageLoadingCell.Size.height
        currLoadingLayer.frame.size = CGSize(width: loadingSize, height: loadingSize)
        currLoadingLayer.cornerRadius = loadingSize / 2
        currLoadingLayer.masksToBounds = true
        currLoadingLayer.zPosition = 1

        prevImageView.layer.zPosition = 2
        currImageView.layer.zPosition = 3
        nextImageView.layer.zPosition = 2

        imagesContainer.layer.addSublayer(currLoadingLayer)
        nextPageView.frame.size = nextPageView.intrinsicContentSize

        toolbar.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            toolbarVisibleConstraint =
                make.bottom.equalTo(self).offset(-Globals.bestBottomMargin).constraint
            toolbarHiddenConstraint = make.top.equalTo(self.snp.bottom).constraint
        }
        toolbarHiddenConstraint.deactivate()

        toolbarBlackBar.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(toolbar.snp.bottom)
            make.height.equalTo(Globals.bestBottomMargin)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let imageWidth = frame.width - Size.insets.sides - 2 * Size.lilBits
        let imageHeight = frame.height - Size.insets.tops
        imagesContainer.frame.size.width = imageWidth * 3 + Size.insets.sides
        imagesContainer.frame.size.height = frame.height
        imagesContainer.frame.origin.x = -imageWidth + Size.lilBits + gestureDeltaX
        imagesContainer.frame.origin.y = 0

        let views = [prevImageView, currImageView, nextImageView]
        views.eachPair { prevView, view in
            view.frame.origin.y = Size.insets.top
            view.frame.size = CGSize(
                width: imageWidth,
                height: imageHeight
            )

            if let prevView = prevView {
                view.frame.origin.x = prevView.frame.maxX + Size.insets.left
            }
            else {
                view.frame.origin.x = 0
            }
        }

        currImageFrame = currImageView.frame
        prevImageView.layer.zPosition = 2
        currImageView.layer.zPosition = 3
        nextImageView.layer.zPosition = 2

        currLoadingLayer.position = currImageView.frame.center
        toolbarGradientLayer.frame = toolbar.bounds.fromBottom().grow(
            up: Size.toolbarGradientHeight
        )

        nextPageView.center = CGPoint(
            x: nextImageView.frame.minX + nextPageViewWidth,
            y: nextImageView.frame.midY
        )

        if !isLoadingMore {
            let theta: CGFloat = clip(
                map(-gestureDeltaX, fromInterval: (minX, maxX), toInterval: (minAngle, maxAngle)),
                min: minAngle,
                max: maxAngle
            )
            let transform = CGAffineTransform(rotationAngle: theta)
            nextPageView.transform = transform
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        if window != nil {
            currLoadingLayer.startAnimating()
        }
    }

    @objc
    func pinchGestureMovement(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .began {
            gesture.scale = imageScale
        }
        else if gesture.state == .changed {
            imageScale = gesture.scale
            updateImageTransform()
        }
        else if gesture.state == .ended {
            normalizeImageTransform()
        }
    }

    @objc
    func imagePanGestureMovement(gesture: UIPanGestureRecognizer) {
        var translation = gesture.translation(in: self)
        translation.x /= imageScale
        translation.y /= imageScale

        if gesture.state == .began {
            tempOffset = imageOffset
        }
        else if gesture.state == .changed {
            imageOffset = CGPoint(
                x: tempOffset.x + translation.x,
                y: tempOffset.y + translation.y
            )
            updateImageTransform()
        }
        else if gesture.state == .ended {
            normalizeImageTransform()
        }
    }

    @objc
    func scrollPanGestureMovement(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)

        if gesture.state == .began {
            imageScale = 1
            imageOffset = .zero
            updateImageTransform()
        }
        else if gesture.state == .ended {
            let velocity = gesture.velocity(in: self)

            let delta: Delta?
            let urls = delegate.imageURLsForScreen()
            if translation.x < -20 && velocity.x < 0 && urls.next != nil {
                delta = .next
            }
            else if translation.x > 20 && velocity.x > 0 && urls.prev != nil {
                delta = .prev
            }
            else {
                delta = nil
            }

            let shouldLoadMore = -gestureDeltaX >= maxX && canLoadMore()
            let imageWidth = frame.width - Size.insets.sides - 2 * Size.lilBits
            if let delta = delta {
                switch delta {
                case .prev:
                    (prevImageView, currImageView, nextImageView) = (
                        nextImageView, prevImageView, currImageView
                    )
                    (prevURL, currURL, nextURL) = (nil, prevURL, currURL)

                    setNeedsLayout()
                    layoutIfNeeded()
                    imagesContainer.frame.origin.x -= imageWidth
                case .next:
                    (prevImageView, currImageView, nextImageView) = (
                        currImageView, nextImageView, prevImageView
                    )
                    (prevURL, currURL, nextURL) = (currURL, nextURL, nil)

                    setNeedsLayout()
                    layoutIfNeeded()
                    imagesContainer.frame.origin.x += imageWidth
                }
            }

            if let delta = delta {
                let showHideToolbar = delegate.isDifferentPost(delta: delta.rawValue)
                if showHideToolbar {
                    toggleToolbar()
                }
                delegate.didMoveBy(delta: delta.rawValue)
                updateImages(updateToolbar: !showHideToolbar)
            }

            elloAnimate {
                if shouldLoadMore {
                    self.nextPageView.startAnimating()
                    self.gestureDeltaX = -self.maxX
                }
                else {
                    self.gestureDeltaX = 0
                }

                self.setNeedsLayout()
                self.layoutIfNeeded()
                self.scrollPanGesture.isEnabled = false

                self.prevImageView.alpha = 0.5
                self.currImageView.alpha = 1
                self.nextImageView.alpha = 0.5
            }.done {
                self.enableGestures()
            }

            if shouldLoadMore {
                loadMoreImages()
            }
        }
        else {
            gestureDeltaX = translation.x
            setNeedsLayout()
        }
    }

    private func canLoadMore() -> Bool {
        return nextURL == nil && delegate.canLoadMore()
    }

    private func loadMoreImages() {
        delegate.loadMoreImages().ensure {
            elloAnimate {
                self.gestureDeltaX = 0
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }.done {
                self.nextPageView.stopAnimating()
                self.enableGestures()
            }
        }.ignoreErrors()
    }

    private func enableGestures() {
        imagePanGesture.isEnabled = isZoomed
        zoomOutGesture.isEnabled = isZoomed

        scrollPanGesture.isEnabled = !isZoomed && !isLoadingMore
        loveGesture.isEnabled = !isZoomed && !isLoadingMore
        dismissGesture.isEnabled = !isZoomed
    }

    private func showToolbar() {
        self.toolbarVisibleConstraint.activate()
        self.toolbarHiddenConstraint.deactivate()
        elloAnimate {
            self.toolbar.frame.origin.y = self.frame.height - self.toolbar.frame.height
                - Globals.bestBottomMargin
            self.toolbarBlackBar.frame.origin.y = self.toolbar.frame.maxY
        }
    }

    private func hideToolbar() {
        self.toolbarVisibleConstraint.deactivate()
        self.toolbarHiddenConstraint.activate()
        elloAnimate {
            self.toolbar.frame.origin.y = self.frame.height
            self.toolbarBlackBar.frame.origin.y = self.toolbar.frame.maxY
        }
    }

    private func toggleToolbar() {
        elloAnimate {
            self.hideToolbar()
        }.done {
            delay(0.3) {
                self.delegate.configureToolbar(self.toolbar)
                self.toolbar.layoutIfNeeded()
                self.showToolbar()
            }
        }
    }

    func updateImages(updateToolbar: Bool) {
        let urls = delegate.imageURLsForScreen()
        let newPrevURL = urls.prev
        let newCurrURL = urls.current
        let newNextURL = urls.next

        if let imageSuperview = currImageView.superview {
            currImageView.removeFromSuperview()
            imageSuperview.addSubview(currImageView)
        }

        let items = [
            (newPrevURL, prevURL, prevImageView),
            (newCurrURL, currURL, currImageView),
            (newNextURL, nextURL, nextImageView),
        ]
        for (newURL, oldURL, imageView) in items {
            if newURL == nil || newURL != oldURL {
                imageView.pin_cancelImageDownload()
                imageView.image = nil
            }

            let wasCurrent = (imageView == currImageView)
            if wasCurrent { currLoadingLayer.opacity = 1 }
            if let url = newURL, newURL != oldURL {
                imageView.pin_setImage(from: url) { result in
                    let isCurrent = imageView == self.currImageView
                    if isCurrent && result.image != nil {
                        self.currLoadingLayer.opacity = 0
                    }
                }
            }
            else if wasCurrent && imageView.image != nil {
                currLoadingLayer.opacity = 0
            }
        }

        prevURL = newPrevURL
        currURL = newCurrURL
        nextURL = newNextURL

        nextPageView.isHidden = true
        if updateToolbar {
            delegate.configureToolbar(toolbar)
        }

        if canLoadMore() {
            nextPageView.isVisible = true
        }
    }

    private func normalizeImageTransform() {
        var adjusted = false
        if imageScale < 1 {
            imageScale = 1
            imageOffset = .zero
            adjusted = true
        }
        else {
            guard let imageSize = currImageView.image?.size else { return }

            let actualImageScale = min(
                currImageView.frame.width / imageSize.width,
                currImageView.frame.height / imageSize.height
            )
            let actualImageSize = CGSize(
                width: imageSize.width * actualImageScale,
                height: imageSize.height * actualImageScale
            )
            let adjustedActualFrame = CGRect(
                x: currImageView.frame.minX + (currImageView.frame.width - actualImageSize.width)
                    / 2,
                y: currImageView.frame.minY + (currImageView.frame.height - actualImageSize.height)
                    / 2,
                width: actualImageSize.width,
                height: actualImageSize.height
            )

            if adjustedActualFrame.width < currImageFrame.width {
                if adjustedActualFrame.minX < currImageFrame.minX {
                    let delta = currImageFrame.minX - adjustedActualFrame.minX
                    imageOffset.x += delta / imageScale
                    adjusted = true
                }
                else if adjustedActualFrame.maxX > currImageFrame.maxX {
                    let delta = adjustedActualFrame.maxX - currImageFrame.maxX
                    imageOffset.x -= delta / imageScale
                    adjusted = true
                }
            }
            else {
                if adjustedActualFrame.minX > currImageFrame.minX {
                    let delta = adjustedActualFrame.minX - currImageFrame.minX
                    imageOffset.x -= delta / imageScale
                    adjusted = true
                }
                else if adjustedActualFrame.maxX < currImageFrame.maxX {
                    let delta = currImageFrame.maxX - adjustedActualFrame.maxX
                    imageOffset.x += delta / imageScale
                    adjusted = true
                }
            }

            if adjustedActualFrame.height < currImageFrame.height {
                if adjustedActualFrame.minY < currImageFrame.minY {
                    let delta = currImageFrame.minY - adjustedActualFrame.minY
                    imageOffset.y += delta / imageScale
                    adjusted = true
                }
                else if adjustedActualFrame.maxY > currImageFrame.maxY {
                    let delta = adjustedActualFrame.maxY - currImageFrame.maxY
                    imageOffset.y -= delta / imageScale
                    adjusted = true
                }
            }
            else {
                if adjustedActualFrame.minY > currImageFrame.minY {
                    let delta = adjustedActualFrame.minY - currImageFrame.minY
                    imageOffset.y -= delta / imageScale
                    adjusted = true
                }
                else if adjustedActualFrame.maxY < currImageFrame.maxY {
                    let delta = currImageFrame.maxY - adjustedActualFrame.maxY
                    imageOffset.y += delta / imageScale
                    adjusted = true
                }
            }
        }

        if adjusted {
            updateImageTransform()
        }
    }

    private func updateImageTransform() {
        if imageScale > 1 {
            hideToolbar()
        }
        else {
            showToolbar()
        }
        enableGestures()

        var transform = CATransform3DIdentity
        transform = CATransform3DScale(transform, imageScale, imageScale, 1.01)
        transform = CATransform3DTranslate(transform, imageOffset.x, imageOffset.y, 0)

        elloAnimate {
            self.currImageView.layer.transform = transform
        }
    }
}

extension LightboxScreen {
    @objc
    func loveAction(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        delegate.loveAction(animationLocation: location)
    }

    @objc
    func zoomOutAction() {
        imageScale = 1
        imageOffset = .zero
        updateImageTransform()
    }

    @objc
    func dismissAction() {
        delegate.dismissAction()
    }
}

extension LightboxScreen: PostToolbarDelegate {
    @objc
    func toolbarViewsButtonTapped(viewsControl control: ImageLabelControl) {
        delegate.viewAction()
    }

    @objc
    func toolbarCommentsButtonTapped(commentsControl control: ImageLabelControl) {
        delegate.commentsAction()
    }

    @objc
    func toolbarLovesButtonTapped(lovesControl control: ImageLabelControl) {
        delegate.loveAction()
    }

    @objc
    func toolbarRepostButtonTapped(repostControl control: ImageLabelControl) {
        delegate.repostAction()
    }

    @objc
    func toolbarShareButtonTapped(shareControl control: UIView) {
        delegate.shareAction(control: control)
    }
}

extension LightboxScreen {
    private static func generateGradientLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.locations = [0, 1]
        layer.colors = [
            UIColor(hex: 0x000000, alpha: 1).cgColor,
            UIColor(hex: 0x000000, alpha: 0).cgColor,
        ]
        layer.startPoint = CGPoint(x: 0.5, y: 1)
        layer.endPoint = CGPoint(x: 0.5, y: 0)
        return layer
    }
}
