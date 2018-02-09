////
///  StreamImageViewer.swift
//

import FLAnimatedImage
import PromiseKit


class StreamImageViewer {
    var prevWindowSize: CGSize?

    weak var streamViewController: StreamViewController?

    init(streamViewController: StreamViewController) {
        self.streamViewController = streamViewController
    }
}


// MARK: Public
extension StreamImageViewer {
    func imageTapped(selected index: Int, allItems: [LightboxViewController.Item], currentUser: User?) {
        guard let streamViewController = streamViewController else { return }

        // tell AppDelegate to allow rotation
        AppDelegate.restrictRotation = false
        prevWindowSize = UIWindow.windowSize()

        let lightboxViewController = LightboxViewController(selected: index, allItems: allItems)
        lightboxViewController.currentUser = currentUser
        lightboxViewController.delegate = self
        lightboxViewController.streamViewController = streamViewController
        streamViewController.present(lightboxViewController, animated: true, completion: nil)
    }
}

extension StreamImageViewer: LightboxControllerDelegate {
    func lightboxWillDismiss() {
        AppDelegate.restrictRotation = true

        if let prevSize = prevWindowSize, prevSize != UIWindow.windowSize() {
            postNotification(Application.Notifications.ViewSizeWillChange, value: UIWindow.windowSize())
        }
    }
}
