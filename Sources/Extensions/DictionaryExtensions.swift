////
///  DictionaryExtensions.swift
//

extension Dictionary {
    func convert<A, B>(_ fn: (Key, Value) -> (A, B)) -> [A: B] {
        var retVal: [A: B] = [:]
        for (key, value) in self {
            let (a, b) = fn(key, value)
            retVal[a] = b
        }
        return retVal
    }

    mutating func merge<K, V>(_ dict: [K: V]){
        for (k, v) in dict {
            self.updateValue(v as! Value, forKey: k as! Key)
        }
    }
}

func +<K, V> (left: [K: V], right: [K: V]) -> [K: V] {
    var d: [K: V] = [:]
    d.merge(left)
    d.merge(right)
    return d
}
