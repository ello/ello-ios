////
///  NotificationOverrides.swift
//

class Keyboard {
    static let shared = Keyboard()
    var options = UIView.AnimationOptions.curveLinear
    var duration: Double = 0.0
}

struct Preloader {
    func preloadImages(_ jsonables: [Model]) {
    }
}
