////
///  Authorable.swift
//


@objc
public protocol Authorable {
    var createdAt: NSDate { get }
    var author: User? { get }
}
