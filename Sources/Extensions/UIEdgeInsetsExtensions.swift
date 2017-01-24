////
///  UIEdgeInsetsExtensions.swift
//

import CoreGraphics
import UIKit
import Foundation

extension UIEdgeInsets {
    init(top: CGFloat) {
        self.init(top: top, left: 0, bottom: 0, right: 0)
    }

    init(left: CGFloat) {
        self.init(top: 0, left: left, bottom: 0, right: 0)
    }

    init(bottom: CGFloat) {
        self.init(top: 0, left: 0, bottom: bottom, right: 0)
    }

    init(right: CGFloat) {
        self.init(top: 0, left: 0, bottom: 0, right: right)
    }

    init(tops: CGFloat) {
        self.init(top: tops, left: 0, bottom: tops, right: 0)
    }

    init(sides: CGFloat) {
        self.init(top: 0, left: sides, bottom: 0, right: sides)
    }

    init(tops: CGFloat, sides: CGFloat) {
        self.init(top: tops, left: sides, bottom: tops, right: sides)
    }

    init(all: CGFloat) {
        self.init(top: all, left: all, bottom: all, right: all)
    }

}

extension UIEdgeInsets {
    init(topMargin: CGFloat) {
        self.init(top: -topMargin, left: 0, bottom: 0, right: 0)
    }

    init(leftMargin: CGFloat) {
        self.init(top: 0, left: -leftMargin, bottom: 0, right: 0)
    }

    init(bottomMargin: CGFloat) {
        self.init(top: 0, left: 0, bottom: -bottomMargin, right: 0)
    }

    init(rightMargin: CGFloat) {
        self.init(top: 0, left: 0, bottom: 0, right: -rightMargin)
    }

    init(topMargins: CGFloat) {
        self.init(top: -topMargins, left: 0, bottom: -topMargins, right: 0)
    }

    init(sideMargins: CGFloat) {
        self.init(top: 0, left: -sideMargins, bottom: 0, right: -sideMargins)
    }

    init(topMargins: CGFloat, sideMargins: CGFloat) {
        self.init(top: -topMargins, left: -sideMargins, bottom: -topMargins, right: -sideMargins)
    }

    init(margins: CGFloat) {
        self.init(top: -margins, left: -margins, bottom: -margins, right: -margins)
    }
}
