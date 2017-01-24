////
///  Array.swift
//

extension Array {
    func safeValue(_ index: Int) -> Element? {
        return (startIndex..<endIndex).contains(index) ? self[index] : .none
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
