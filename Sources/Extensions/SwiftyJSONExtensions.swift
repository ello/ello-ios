////
///  SwiftyJSONExtensions.swift
//

import SwiftyJSON

extension JSON {
    public var dateValue: Date {
        return date ?? Globals.now
    }

    public var date: Date? {
        return string?.toDate()
    }

    public var idValue: String {
        return id ?? ""
    }

    public var id: String? {
        get {
            if let string = string {
                return string
            }
            if let int = int {
                return "\(int)"
            }
            return nil
        }
        set {
            string = newValue
            int = nil
        }
    }
}
