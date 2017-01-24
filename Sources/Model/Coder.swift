////
///  Decoder.swift
//

import Foundation

struct Coder {
    let coder: NSCoder

    init(_ coder: NSCoder) {
        self.coder = coder
    }
}

extension Coder {
    func decodeKey<T>(_ key: String) -> T {
        return coder.decodeObject(forKey: key) as! T
    }

    func decodeKey(_ key: String) -> Bool {
        if coder.containsValue(forKey: key) {
            return coder.decodeBool(forKey: key)
        } else {
            return false
        }
    }

    func decodeKey(_ key: String) -> Int {
        return Int(coder.decodeCInt(forKey: key))
    }
}

extension Coder {
    func decodeOptionalKey<T>(_ key: String) -> T? {
        if coder.containsValue(forKey: key) {
            return coder.decodeObject(forKey: key) as? T
        } else {
            return .none
        }
    }

    func decodeOptionalKey(_ key: String) -> Bool? {
        if coder.containsValue(forKey: key) {
            return coder.decodeBool(forKey: key)
        } else {
            return .none
        }
    }

    func decodeOptionalKey(_ key: String) -> Int? {
        if coder.containsValue(forKey: key) {
            return Int(coder.decodeCInt(forKey: key))
        } else {
            return .none
        }
    }
}

extension Coder {
    func encodeObject(_ obj: Any?, forKey key: String) {
        if let bool = obj as? Bool {
            coder.encode(bool, forKey: key)
        }
        else if let int = obj as? Int {
            coder.encode(Int64(int), forKey: key)
        }
        else if obj != nil {
            coder.encode(obj, forKey: key)
        }
    }
}
