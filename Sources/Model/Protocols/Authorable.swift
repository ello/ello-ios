////
///  Authorable.swift
//


@objc
protocol Authorable {
    var createdAt: Date { get }
    var author: User? { get }
}
