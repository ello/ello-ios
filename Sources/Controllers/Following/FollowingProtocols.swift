////
///  FollowingProtocols.swift
//

protocol FollowingScreenDelegate: class {
    func scrollToTop()
    func loadNewPosts()
}

protocol FollowingScreenProtocol: StreamableScreenProtocol {
    var newPostsButtonVisible: Bool { get set }
}
