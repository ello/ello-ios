////
///  Conversation.swift
//

import Crashlytics
import SwiftyJSON

let ConversationVersion = 1

@objc(Conversation)
public final class Conversation: JSONAble {

    //Ecto
    public let id: String
    public let insertedAt: NSDate
    public let updatedAt: NSDate

    public let name: String
    public var members: [ConversationMember]? {
        return getLinkArray("members") as? [ConversationMember]
    }

    public var messages: [Message]? {
        return getLinkArray("messages") as? [Message]
    }

// MARK: Initialization

    public init(id: String,
                insertedAt: NSDate,
                updatedAt: NSDate,
                name: String)
    {
        self.id = id
        self.insertedAt = insertedAt
        self.updatedAt = updatedAt
        self.name = name
        super.init(version: ConversationVersion)
    }

// MARK: NSCoding

    public required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        // Ecto
        self.id = decoder.decodeKey("id")
        self.insertedAt = decoder.decodeKey("insertedAt")
        self.updatedAt = decoder.decodeKey("updatedAt")
        self.name = decoder.decodeKey("name")
        super.init(coder: decoder.coder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        let coder = Coder(encoder)
        // ecto
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(insertedAt, forKey: "insertedAt")
        coder.encodeObject(updatedAt, forKey: "updatedAt")
        coder.encodeObject(name, forKey: "name")
        super.encodeWithCoder(coder.coder)
    }

// MARK: JSONAble

    override class public func fromJSON(data: [String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        Crashlytics.sharedInstance().setObjectValue(json.rawString(), forKey: CrashlyticsKey.ConversationFromJSON.rawValue)
        // create conversation
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

        var updatedAt: NSDate
        if let date = json["inserted_at"].stringValue.toNSDate() {
            // good to go
            updatedAt = date
        }
        else {
            updatedAt = NSDate()
            // send data to segment to try to get more data about this
            Tracker.sharedTracker.createdAtCrash("Conversation", json: json.rawString())
        }

        let conversation = Conversation(
            id: json["id"].stringValue,
            insertedAt: insertedAt,
            updatedAt: updatedAt,
            name: json["name"].stringValue
        )

        return conversation
    }
}
