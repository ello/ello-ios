////
///  ConversationMember.swift
//

import Crashlytics
import SwiftyJSON

let ConversationMemberVersion = 1

@objc(ConversationMember)
public final class ConversationMember: JSONAble {

    //Ecto
    public let id: String
    public let insertedAt: NSDate

    // required
    public let userId: String
    public let username: String
    public let conversationId: String

    public var conversation: Conversation? {
        return ElloLinkedStore.sharedInstance.getObject(self.conversationId, inCollection: MappingType.ConversationsType.rawValue) as? Conversation
    }

// MARK: Initialization

    public init(id: String,
                insertedAt: NSDate,
                userId: String,
                username: String,
                conversationId: String)
    {
        self.id = id
        self.insertedAt = insertedAt
        self.userId = userId
        self.username = username
        self.conversationId = conversationId

        super.init(version: ConversationMemberVersion)
    }

// MARK: NSCoding

    public required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)

        self.id = decoder.decodeKey("id")
        self.insertedAt = decoder.decodeKey("insertedAt")
        self.userId = decoder.decodeKey("userId")
        self.username = decoder.decodeKey("username")
        self.conversationId = decoder.decodeKey("conversationId")
        super.init(coder: decoder.coder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        let coder = Coder(encoder)
        // ecto
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(insertedAt, forKey: "insertedAt")
        coder.encodeObject(userId, forKey: "userId")
        coder.encodeObject(username, forKey: "username")
        coder.encodeObject(conversationId, forKey: "conversationId")
        super.encodeWithCoder(coder.coder)
    }

// MARK: JSONAble

    override class public func fromJSON(data: [String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        Crashlytics.sharedInstance().setObjectValue(json.rawString(), forKey: CrashlyticsKey.ConversationMemberFromJSON.rawValue)
        // create conversation member
        var insertedAt: NSDate
        if let date = json["inserted_at"].stringValue.toNSDate() {
            // good to go
            insertedAt = date
        }
        else {
            insertedAt = NSDate()
            // send data to segment to try to get more data about this
            Tracker.sharedTracker.createdAtCrash("ConversationMember", json: json.rawString())
        }

        let conversationMember = ConversationMember(
            id: json["id"].stringValue,
            insertedAt: insertedAt,
            userId: json["user_id"].stringValue,
            username: json["username"].stringValue,
            conversationId: json["conversation_id"].stringValue
        )

        return conversationMember
    }
}
