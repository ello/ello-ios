////
///  StreamCellItemParserExt.swift
//

@testable import Ello


extension StreamCellItemParser {

    func parseAllForTesting(_ items: [JSONAble]) -> [StreamCellItem] {
        var retItems = [StreamCellItem]()
        for item in items {
            if let post = item as? Post {
                retItems += testingPostCellItems([post], streamKind: .following, forceGrid: false)
            }
            else if let comment = item as? ElloComment {
                retItems += testingCommentCellItems([comment])
            }
            else if item is Ello.Notification {
                retItems += testingTypicalCellItems([item], type: .notification)
            }
            else if item is Announcement {
                retItems += testingTypicalCellItems([item], type: .announcement)
            }
            else if item is Editorial {
                retItems += testingTypicalCellItems([item], type: .editorial)
            }
            else if item is User {
                retItems += testingTypicalCellItems([item], type: .userListItem)
            }
        }
        return retItems
    }

}
