////
///  StreamImageViewer.swift
//

import FLAnimatedImage
import JTSImageViewController

class StreamImageViewer: NSObject {
    var prevWindowSize: CGSize?

    weak var presentingController: StreamViewController?
    weak var imageView: UIImageView?

    init(presentingController: StreamViewController) {
        self.presentingController = presentingController
    }
}


// MARK: Public
extension StreamImageViewer {
    func imageTapped(_ imageView: FLAnimatedImageView, imageURL: URL?) {
        guard let presentingController = presentingController else { return }

        // tell AppDelegate to allow rotation
        AppDelegate.restrictRotation = false
        prevWindowSize = UIWindow.windowSize()

        self.imageView = imageView
        imageView.isHidden = true
        let imageInfo = JTSImageInfo()
        if let imageURL = imageURL {
            imageInfo.imageURL = imageURL
        }
        else {
            imageInfo.image = imageView.image
        }
        imageInfo.referenceRect = imageView.frame
        imageInfo.referenceView = imageView.superview
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.image, backgroundStyle: JTSImageViewControllerBackgroundOptions())
        let transition: JTSImageViewControllerTransition = .fromOriginalPosition
        imageViewer?.show(from: presentingController, transition: transition)
        imageViewer?.optionsDelegate = self
        imageViewer?.dismissalDelegate = self
    }
}


// MARK: JTSImageViewControllerOptionsDelegate
extension StreamImageViewer: JTSImageViewControllerOptionsDelegate {
    func alphaForBackgroundDimmingOverlay(inImageViewer imageViewer: JTSImageViewController) -> CGFloat {
        return 1.0
    }
}


// MARK: JTSImageViewControllerDismissalDelegate
extension StreamImageViewer: JTSImageViewControllerDismissalDelegate {
    func imageViewerDidDismiss(_ imageViewer: JTSImageViewController) {
        if let prevSize = prevWindowSize, prevSize != UIWindow.windowSize() {
            postNotification(Application.Notifications.ViewSizeWillChange, value: UIWindow.windowSize())
        }
    }

    func imageViewerWillDismiss(_ imageViewer: JTSImageViewController) {
        self.imageView?.isHidden = false
        AppDelegate.restrictRotation = true
    }

    func imageViewerWillAnimateDismissal(_ imageViewer: JTSImageViewController, withContainerView containerView: UIView, duration: CGFloat) {}
}
