////
///  StreamCellItem.swift
//

enum StreamCellState {
    case none
    case loading
    case expanded
    case collapsed
}


final class StreamCellItem: NSObject, NSCopying {
    typealias CalculatorGeneratorWithStreamKind = (StreamKind, StreamCellItem, CGFloat, Int) -> CellSizeCalculator
    typealias CalculatorGenerator = (StreamCellItem, CGFloat, Int) -> CellSizeCalculator

    var jsonable: Model
    var groupId: String?
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

    convenience init(jsonable: Model, type: StreamCellType, placeholderType: StreamCellType.PlaceholderType, groupId: String? = nil) {
        self.init(jsonable: jsonable, type: type, groupId: groupId)
        self.placeholderType = placeholderType
    }

    required init(jsonable: Model, type: StreamCellType, groupId: String? = nil) {
        self.jsonable = jsonable
        self.type = type

        if let groupId = groupId {
            self.groupId = groupId
        }
        else if type == .createComment, let comment = jsonable as? ElloComment {
            self.groupId = "Post-\(comment.postId)"
        }
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


    static var textCellSizeCalculator: CalculatorGeneratorWithStreamKind = StreamTextCellSizeCalculator.init
    static var imageCellSizeCalculator: CalculatorGeneratorWithStreamKind = StreamImageCellSizeCalculator.init
    static var notificationCellSizeCalculator: CalculatorGenerator = NotificationCellSizeCalculator.init
    static var announcementCellSizeCalculator: CalculatorGenerator = AnnouncementCellSizeCalculator.init
    static var promoHeaderCellSizeCalculator: CalculatorGenerator = PromotionalHeaderCellSizeCalculator.init
    static var profileNameCellSizeCalculator: CalculatorGenerator = ProfileHeaderNamesSizeCalculator.init
    static var profileBioCellSizeCalculator: CalculatorGenerator = ProfileHeaderBioSizeCalculator.init
    static var profileLinksCellSizeCalculator: CalculatorGenerator = ProfileHeaderLinksSizeCalculator.init
    static var artistInviteCellSizeCalculator: CalculatorGenerator = ArtistInviteCellSizeCalculator.init

    func sizeCalculator(streamKind: StreamKind, width: CGFloat, columnCount: Int) -> CellSizeCalculator? {
        if type.data is TextRegion {
            return StreamCellItem.textCellSizeCalculator(streamKind, self, width, columnCount)
        }
        else if type.data is ImageRegion || type.data is EmbedRegion {
            return StreamCellItem.imageCellSizeCalculator(streamKind, self, width, columnCount)
        }
        else if type == .notification {
            return StreamCellItem.notificationCellSizeCalculator(self, width, columnCount)
        }
        else if type == .announcement {
            return StreamCellItem.announcementCellSizeCalculator(self, width, columnCount)
        }
        else if type == .promotionalHeader {
            return StreamCellItem.promoHeaderCellSizeCalculator(self, width, columnCount)
        }
        else if type == .profileHeaderName {
            return StreamCellItem.profileNameCellSizeCalculator(self, width, columnCount)
        }
        else if type == .profileHeaderBio {
            return StreamCellItem.profileBioCellSizeCalculator(self, width, columnCount)
        }
        else if type == .profileHeaderLinks {
            return StreamCellItem.profileLinksCellSizeCalculator(self, width, columnCount)
        }
        else if jsonable is ArtistInvite {
            return StreamCellItem.artistInviteCellSizeCalculator(self, width, columnCount)
        }

        return nil
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
