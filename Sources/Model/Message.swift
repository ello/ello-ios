////
///  Message.swift
//

import Crashlytics
import SwiftyJSON

let MessageVersion = 1

@objc(Message)
public final class Message: JSONAble {

    // Ecto
    public let id: String
    public let insertedAt: NSDate

    // required
    public let authorId: String
    public let conversationId: String
    public let body: String

    public var author: ConversationMember? {
        return ElloLinkedStore.sharedInstance.getObject(self.authorId, inCollection: MappingType.ConversationMembersType.rawValue) as? ConversationMember
    }

    public var conversation: Conversation? {
        return ElloLinkedStore.sharedInstance.getObject(self.conversationId, inCollection: MappingType.ConversationsType.rawValue) as? Conversation
    }

// MARK: Initialization

    public init(id: String,
                insertedAt: NSDate,
                authorId: String,
                conversationId: String,
                body: String)
    {
        self.id = id
        self.insertedAt = insertedAt
        self.authorId = authorId
        self.conversationId = conversationId
        self.body = body
        super.init(version: MessageVersion)
    }

// MARK: NSCoding

    public required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        // Ecto
        self.id = decoder.decodeKey("id")
        self.insertedAt = decoder.decodeKey("insertedAt")
        // required
        self.authorId = decoder.decodeKey("authorId")
        self.conversationId = decoder.decodeKey("conversationId")
        self.body = decoder.decodeKey("body")
        super.init(coder: decoder.coder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        let coder = Coder(encoder)
        // ecto
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(insertedAt, forKey: "insertedAt")
        // required
        coder.encodeObject(authorId, forKey: "authorId")
        coder.encodeObject(conversationId, forKey: "conversationId")
        coder.encodeObject(body, forKey: "body")

        super.encodeWithCoder(coder.coder)
    }

// MARK: JSONAble

    override class public func fromJSON(data: [String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        Crashlytics.sharedInstance().setObjectValue(json.rawString(), forKey: CrashlyticsKey.MessageFromJSON.rawValue)
        // create comment
        var insertedAt: NSDate
        if let date = json["inserted_at"].stringValue.toNSDate() {
            // good to go
            insertedAt = date
        }
        else {
            insertedAt = NSDate()
            // send data to segment to try to get more data about this
            Tracker.sharedTracker.createdAtCrash("Message", json: json.rawString())
        }

        let message = Message(
            id: json["id"].stringValue,
            insertedAt: insertedAt,
            authorId: json["author_id"].stringValue,
            conversationId: json["conversation_id"].stringValue,
            body: json["body"].stringValue
        )

       return message
    }
}
