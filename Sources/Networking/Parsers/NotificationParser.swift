////
///  NotificationParser.swift
//

import SwiftyJSON


class NotificationParser: IdParser {
    init() {
        super.init(table: .notificationsType)
    }

    override func flatten(json _json: JSON, identifier: Identifier, db: inout Database) {
        var json = _json

        let parser: Parser? = Notification.SubjectType(rawValue: json["subjectType"].stringValue)
            .flatMap { subjectType in
                switch subjectType {
                case .post: return PostParser()
                case .user: return UserParser()
                case .comment: return CommentParser()
                case .categoryPost: return CategoryPostParser()
                case .unknown: return nil
                }
            }

        let subjectJson = json["subject"]
        if let parser = parser, let subjectIdentifier = parser.identifier(json: subjectJson) {
            parser.flatten(json: subjectJson, identifier: subjectIdentifier, db: &db)
            json["links"]["subject"] = [
                "id": subjectIdentifier.id,
                "type": subjectIdentifier.table.rawValue,
            ]
        }

        super.flatten(json: json, identifier: identifier, db: &db)
    }

    override func parse(json: JSON) -> Notification {
        let notification = Notification(id: json["id"].idValue,
            createdAt: json["createdAt"].dateValue,
            kind: Notification.Kind(rawValue: json["kind"].stringValue) ?? .unknown,
            subjectType: Notification.SubjectType(rawValue: json["subjectType"].stringValue) ?? .unknown)

        notification.mergeLinks(json["links"].dictionaryObject)

        return notification
    }
}
