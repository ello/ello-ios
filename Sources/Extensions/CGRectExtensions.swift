////
///  CGRectExtensions.swift
//

extension CGRect {
    static var `default`: CGRect = CGRect(origin: .zero, size: CGSize(width: 600, height: 600))

    // MARK: debug
    func tap(_ name: String = "frame") -> CGRect {
        print("\(name): \(self)")
        return self
    }

    // MARK: convenience
    init(x: CGFloat, y: CGFloat, right: CGFloat, bottom: CGFloat) {
        self.init(x: x, y: y, width: right - x, height: bottom - y)
    }

    init(x: CGFloat, y: CGFloat) {
        self.init(x: x, y: y, width: 0, height: 0)
    }

    init(origin: CGPoint) {
        self.init(origin: origin, size: .zero)
    }

    init(width: CGFloat, height: CGFloat) {
        self.init(origin: .zero, size: CGSize(width: width, height: height))
    }

    init(size: CGSize) {
        self.init(origin: .zero, size: size)
    }

    // MARK: helpers
    var x: CGFloat { return origin.x }
    var y: CGFloat { return origin.y }
    var center: CGPoint {
        get { return CGPoint(x: self.midX, y: self.midY) }
        set { origin = CGPoint(x: newValue.x - width / 2, y: newValue.y - height / 2) }
    }

    // MARK: dimension setters
    func at(origin amt: CGPoint) -> CGRect {
        var f = self
        f.origin = amt
        return f
    }

    func with(size amt: CGSize) -> CGRect {
        var f = self
        f.size = amt
        return f
    }

    func at(x amt: CGFloat) -> CGRect {
        var f = self
        f.origin.x = amt
        return f
    }

    func at(y amt: CGFloat) -> CGRect {
        var f = self
        f.origin.y = amt
        return f
    }

    func with(width amt: CGFloat) -> CGRect {
        var f = self
        f.size.width = amt
        return f
    }

    func with(height amt: CGFloat) -> CGRect {
        var f = self
        f.size.height = amt
        return f
    }

    // MARK: inset(xxx:)
    func inset(all: CGFloat) -> CGRect {
        return inset(by: UIEdgeInsets(top: all, left: all, bottom: all, right: all))
    }

    func inset(topBottom: CGFloat, sides: CGFloat) -> CGRect {
        return inset(by: UIEdgeInsets(top: topBottom, left: sides, bottom: topBottom, right: sides))
    }

    func inset(topBottom: CGFloat) -> CGRect {
        return inset(by: UIEdgeInsets(top: topBottom, left: 0, bottom: topBottom, right: 0))
    }

    func inset(sides: CGFloat) -> CGRect {
        return inset(by: UIEdgeInsets(top: 0, left: sides, bottom: 0, right: sides))
    }

    func inset(top: CGFloat, sides: CGFloat, bottom: CGFloat) -> CGRect {
        return inset(by: UIEdgeInsets(top: top, left: sides, bottom: bottom, right: sides))
    }

    func inset(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> CGRect {
        return inset(by: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right))
    }

    func inset(_ insets: UIEdgeInsets) -> CGRect {
        return inset(by: insets)
    }

    // MARK: shrink(xxx:)
    func shrink(left amt: CGFloat) -> CGRect {
        return inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: amt))
    }

    func shrink(right amt: CGFloat) -> CGRect {
        return inset(by: UIEdgeInsets(top: 0, left: amt, bottom: 0, right: 0))
    }

    func shrink(down amt: CGFloat) -> CGRect {
        return inset(by: UIEdgeInsets(top: amt, left: 0, bottom: 0, right: 0))
    }

    func shrink(up amt: CGFloat) -> CGRect {
        return inset(by: UIEdgeInsets(top: 0, left: 0, bottom: amt, right: 0))
    }

    // MARK: grow(xxx:)
    func grow(_ margins: UIEdgeInsets) -> CGRect {
        return inset(
            by: UIEdgeInsets(
                top: -margins.top,
                left: -margins.left,
                bottom: -margins.bottom,
                right: -margins.right
            )
        )
    }

    func grow(all: CGFloat) -> CGRect {
        return inset(by: UIEdgeInsets(top: -all, left: -all, bottom: -all, right: -all))
    }

    func grow(topBottom: CGFloat, sides: CGFloat) -> CGRect {
        return inset(
            by: UIEdgeInsets(top: -topBottom, left: -sides, bottom: -topBottom, right: -sides)
        )
    }

    func grow(top: CGFloat, sides: CGFloat, bottom: CGFloat) -> CGRect {
        return inset(by: UIEdgeInsets(top: -top, left: -sides, bottom: -bottom, right: -sides))
    }

    func grow(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) -> CGRect {
        return inset(by: UIEdgeInsets(top: -top, left: -left, bottom: -bottom, right: -right))
    }

    func grow(left amt: CGFloat) -> CGRect {
        return inset(by: UIEdgeInsets(top: 0, left: -amt, bottom: 0, right: 0))
    }

    func grow(right amt: CGFloat) -> CGRect {
        return inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -amt))
    }

    func grow(up amt: CGFloat) -> CGRect {
        return inset(by: UIEdgeInsets(top: -amt, left: 0, bottom: 0, right: 0))
    }

    func grow(down amt: CGFloat) -> CGRect {
        return inset(by: UIEdgeInsets(top: 0, left: 0, bottom: -amt, right: 0))
    }

    // MARK: from(xxx:)
    func fromTop() -> CGRect {
        return CGRect(x: minX, y: minY, width: width, height: 0)
    }

    func fromBottom() -> CGRect {
        return CGRect(x: minX, y: maxY, width: width, height: 0)
    }

    func fromLeft() -> CGRect {
        return CGRect(x: minX, y: minY, width: 0, height: height)
    }

    func fromRight() -> CGRect {
        return CGRect(x: maxX, y: minY, width: 0, height: height)
    }

    // MARK: shift(xxx:)
    func shift(up amt: CGFloat) -> CGRect {
        return at(y: self.y - amt)
    }

    func shift(down amt: CGFloat) -> CGRect {
        return at(y: self.y + amt)
    }

    func shift(left amt: CGFloat) -> CGRect {
        return at(x: self.x - amt)
    }

    func shift(right amt: CGFloat) -> CGRect {
        return at(x: self.x + amt)
    }

}
