////
///  PostActionable.swift
//


protocol PostActionable: class {
    var postId: String { get }
    var user: User? { get }
}
