////
///  ImageLabelAnimatable.swift
//

@objc
protocol ImageLabelAnimatable {
    @objc optional func animate()
    @objc optional func finishAnimation()
    var enabled: Bool { get set }
    var selected: Bool { get set }
    var highlighted: Bool { get set }
    var view: UIView { get }
}
