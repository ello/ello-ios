////
///  StreamCellItemParserExt.swift
//

@testable import Ello


extension StreamCellItemParser {

    func parseAllForTesting(_ items: [JSONAble]) -> [StreamCellItem] {
        var retItems = [StreamCellItem]()
        for item in items {
            if let post = item as? Post {
                retItems += testingPostCellItems([post], streamKind: .following)
            }
            if let comment = item as? ElloComment {
                retItems += testingCommentCellItems([comment])
            }
            if let notification = item as? Ello.Notification {
                retItems += testingNotificationCellItems([notification])
            }
            if let user = item as? User {
                retItems += testingUserCellItems([user])
            }
        }
        return retItems
    }

}
