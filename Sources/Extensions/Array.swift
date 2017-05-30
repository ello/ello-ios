////
///  Array.swift
//

extension Array {
    func safeValue(_ index: Int) -> Element? {
        return (startIndex..<endIndex).contains(index) ? self[index] : .none
    }

    func safeRange(_ range: CountableRange<Int>) -> [Element] {
        guard
            range.lowerBound <= range.upperBound
        else { return safeRange(range.upperBound ..< range.lowerBound).reversed() }

        guard range.lowerBound != range.upperBound else { return [] }

        let lower = Swift.max(startIndex, range.lowerBound)
        let upper = Swift.min(endIndex, range.upperBound)
        return (lower ..< upper).map { index in
            return self[index]
        }
    }

    func safeRange(_ range: CountableClosedRange<Int>) -> [Element] {
        return safeRange(range.lowerBound ..< (range.upperBound + 1))
    }

    func find(_ test: (_ el: Element) -> Bool) -> Element? {
        for ob in self {
            if test(ob) {
                return ob
            }
        }
        return nil
    }

    func randomItem() -> Element? {
        guard count > 0 else { return nil }
        let index = Int(arc4random_uniform(UInt32(count)))
        return self[index]
    }

}

extension Sequence {

    func any(_ test: (_ el: Iterator.Element) -> Bool) -> Bool {
        for ob in self {
            if test(ob) {
                return true
            }
        }
        return false
    }

    func all(_ test: (_ el: Iterator.Element) -> Bool) -> Bool {
        for ob in self {
            if !test(ob) {
                return false
            }
        }
        return true
    }

    func eachPair(_ block: (Iterator.Element?, Iterator.Element) -> Void) {
        var prev: Iterator.Element?
        for item in self {
            block(prev, item)
            prev = item
        }
    }

    func eachPair(_ block: (Iterator.Element?, Iterator.Element, Bool) -> Void) {
        var prev: Iterator.Element?, last: Iterator.Element?
        for item in self {
            if let last = last {
                block(prev, last, false)
            }
            prev = last
            last = item
        }
        if let last = last {
            block(prev, last, true)
        }
    }

}

extension Array where Element: Equatable {
    func unique() -> [Element] {
        return self.reduce([Element]()) { elements, el in
            if elements.contains(el) {
                return elements
            }
            return elements + [el]
        }
    }

}
