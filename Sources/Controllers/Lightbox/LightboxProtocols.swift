////
///  LightboxProtocols.swift
//

import PromiseKit


protocol LightboxControllerDelegate: class {
    func lightboxWillDismiss()
}

protocol LightboxScreenDelegate: class {
    func viewAction()
    func commentsAction()
    func loveAction(animationLocation: CGPoint)
    func loveAction()
    func repostAction()
    func shareAction(control: UIView)

    func dismissAction()
    func isDifferentPost(delta: Int) -> Bool
    func didMoveBy(delta: Int)
    func imageURLsForScreen() -> (prev: URL?, current: URL, next: URL?)
    func canLoadMore() -> Bool
    func configureToolbar(_: PostToolbar)

    func loadMoreImages() -> Promise<Void>
}

protocol LightboxScreenProtocol: class {
    var toolbar: PostToolbar { get }
    func updateImages(updateToolbar: Bool)
}
