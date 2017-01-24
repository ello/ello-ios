////
///  StreamCellItem.swift
//

import Foundation

enum StreamCellState: CustomStringConvertible, CustomDebugStringConvertible {
    case none
    case loading
    case expanded
    case collapsed

    var description: String {
        switch self {
        case .none: return "None"
        case .loading: return "Loading"
        case .expanded: return "Expanded"
        case .collapsed: return "Collapsed"
        }
    }
    var debugDescription: String { return "StreamCellState.\(description)" }
}


final class StreamCellItem: NSObject, NSCopying {
    var jsonable: JSONAble
    var type: StreamCellType
    var placeholderType: StreamCellType.PlaceholderType?
    var calculatedCellHeights = CalculatedCellHeights()
    var state: StreamCellState = .none

    convenience init(type: StreamCellType) {
        self.init(jsonable: JSONAble(version: 1), type: type)
    }

    convenience init(type: StreamCellType, placeholderType: StreamCellType.PlaceholderType) {
        self.init(jsonable: JSONAble(version: 1), type: type, placeholderType: placeholderType)
    }

    convenience init(jsonable: JSONAble, type: StreamCellType, placeholderType: StreamCellType.PlaceholderType) {
        self.init(jsonable: jsonable, type: type)
        self.placeholderType = placeholderType
    }

    required init(jsonable: JSONAble, type: StreamCellType) {
        self.jsonable = jsonable
        self.type = type
    }

    func copy(with zone: NSZone?) -> Any {
        let copy = type(of: self).init(
            jsonable: self.jsonable,
            type: self.type
            )
        copy.calculatedCellHeights.webContent = self.calculatedCellHeights.webContent
        copy.calculatedCellHeights.oneColumn = self.calculatedCellHeights.oneColumn
        copy.calculatedCellHeights.multiColumn = self.calculatedCellHeights.multiColumn
        return copy
    }

    func alwaysShow() -> Bool {
        if type == .streamLoading {
            return true
        }
        return false
    }

    override var description: String {
        switch type {
        case let .text(data):
            let text: String
            if let textRegion = data as? TextRegion {
                text = textRegion.content
            }
            else {
                text = "unknown"
            }

            return "StreamCellItem(type: \(type.name), jsonable: \(type(of: jsonable)), state: \(state), text: \(text))"
        default:
            return "StreamCellItem(type: \(type.name), jsonable: \(type(of: jsonable)), state: \(state))"
        }
    }

}


func == (lhs: StreamCellItem, rhs: StreamCellItem) -> Bool {
    switch (lhs.type, rhs.type) {
    case (.placeholder, .placeholder):
        return lhs.placeholderType == rhs.placeholderType
    default:
        return lhs === rhs
    }
}
