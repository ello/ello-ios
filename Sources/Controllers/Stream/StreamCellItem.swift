////
///  StreamCellItem.swift
//

enum StreamCellState: String {
    case none = "None"
    case loading = "Loading"
    case expanded = "Expanded"
    case collapsed = "Collapsed"
}


final class StreamCellItem: NSObject, NSCopying {
    var jsonable: Model
    var type: StreamCellType
    var placeholderType: StreamCellType.PlaceholderType?
    var calculatedCellHeights = CalculatedCellHeights()
    var state: StreamCellState = .none
    var forceGrid = false

    func isGridView(streamKind: StreamKind) -> Bool {
        return forceGrid || streamKind.isGridView
    }

    convenience init(type: StreamCellType) {
        self.init(jsonable: Model(version: 1), type: type)
    }

    convenience init(type: StreamCellType, placeholderType: StreamCellType.PlaceholderType) {
        self.init(jsonable: Model(version: 1), type: type, placeholderType: placeholderType)
    }

    convenience init(jsonable: Model, type: StreamCellType, placeholderType: StreamCellType.PlaceholderType) {
        self.init(jsonable: jsonable, type: type)
        self.placeholderType = placeholderType
    }

    required init(jsonable: Model, type: StreamCellType) {
        self.jsonable = jsonable
        self.type = type
    }

    func copy(with zone: NSZone?) -> Any {
        let copy = Swift.type(of: self).init(
            jsonable: self.jsonable,
            type: self.type
            )
        copy.calculatedCellHeights.webContent = self.calculatedCellHeights.webContent
        copy.calculatedCellHeights.oneColumn = self.calculatedCellHeights.oneColumn
        copy.calculatedCellHeights.multiColumn = self.calculatedCellHeights.multiColumn
        return copy
    }

    func alwaysShow() -> Bool {
        if case .streamLoading = type {
            return true
        }
        if case .streamPageLoading = type {
            return true
        }
        return false
    }

    override var description: String {
        var description = "StreamCellItem(type: \(type.reuseIdentifier), jsonable: \(Swift.type(of: jsonable)), state: \(state)"
        if case let .text(data) = type,
            let textRegion = data as? TextRegion
        {
            description += ", text: \(textRegion.content)"
        }

        if let placeholderType = placeholderType {
            description += ", placeholderType: \(placeholderType))"
        }
        description += ")"
        return description
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
