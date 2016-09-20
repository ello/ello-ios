////
///  PostActionable.swift
//


public protocol PostActionable: class {
    var postId: String { get }
    var user: User? { get }
}
