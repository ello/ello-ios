////
///  FollowingProtocols.swift
//

protocol FollowingScreenDelegate: class {
    func scrollToTop()
    func loadNewPosts()
}

protocol FollowingScreenProtocol: StreamableScreenProtocol {
    func showNewPostsButton()
    func hideNewPostsButton()
}
