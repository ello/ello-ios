////
///  Comment.swift
//

import SwiftyJSON


let CommentVersion = 1

@objc(ElloComment)
final class ElloComment: JSONAble, Authorable, Groupable {

    // active record
    let id: String
    let createdAt: Date
    // required
    let authorId: String
    let postId: String
    var content: [Regionable]
    var body: [Regionable]?
    // optional
    var summary: [Regionable]?
    // links
    var assets: [Asset] {
        return getLinkArray("assets") as? [Asset] ?? []
    }
    var author: User? {
        return ElloLinkedStore.sharedInstance.getObject(self.authorId, type: .usersType) as? User
    }
    var parentPost: Post? {
        return ElloLinkedStore.sharedInstance.getObject(self.postId, type: .postsType) as? Post
    }
    var loadedFromPost: Post? {
        return (ElloLinkedStore.sharedInstance.getObject(self.loadedFromPostId, type: .postsType) as? Post) ?? parentPost
    }
    // computed properties
    var groupId: String { return "Post-\(postId)" }
    // to show hide in the stream, and for comment replies
    var loadedFromPostId: String

// MARK: Initialization

    init(id: String,
        createdAt: Date,
        authorId: String,
        postId: String,
        content: [Regionable])
    {
        self.id = id
        self.createdAt = createdAt
        self.authorId = authorId
        self.postId = postId
        self.loadedFromPostId = postId
        self.content = content
        self.loadedFromPostId = postId
        super.init(version: CommentVersion)
    }


// MARK: NSCoding

    required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        // active record
        self.id = decoder.decodeKey("id")
        self.createdAt = decoder.decodeKey("createdAt")
        // required
        self.authorId = decoder.decodeKey("authorId")
        self.postId = decoder.decodeKey("postId")
        self.content = decoder.decodeKey("content")
        self.loadedFromPostId = decoder.decodeKey("loadedFromPostId")
        // optional
        self.body = decoder.decodeOptionalKey("body")
        self.summary = decoder.decodeOptionalKey("summary")
        super.init(coder: decoder.coder)
    }

    override func encode(with encoder: NSCoder) {
        let coder = Coder(encoder)
        // active record
        coder.encodeObject(id, forKey: "id")
        coder.encodeObject(createdAt, forKey: "createdAt")
        // required
        coder.encodeObject(authorId, forKey: "authorId")
        coder.encodeObject(postId, forKey: "postId")
        coder.encodeObject(content, forKey: "content")
        coder.encodeObject(loadedFromPostId, forKey: "loadedFromPostId")
        // optional
        coder.encodeObject(body, forKey: "body")
        coder.encodeObject(summary, forKey: "summary")
        super.encode(with: coder.coder)
    }

// MARK: JSONAble

    override class func fromJSON(_ data: [String: Any]) -> JSONAble {
        let json = JSON(data)
        // create comment
        var createdAt: Date
        if let date = json["created_at"].stringValue.toDate() {
            // good to go
            createdAt = date
        }
        else {
            createdAt = Date()
        }

        let comment = ElloComment(
            id: json["id"].stringValue,
            createdAt: createdAt,
            authorId: json["author_id"].stringValue,
            postId: json["post_id"].stringValue,
            content: RegionParser.regions("content", json: json)
        )
        // optional
        comment.body = RegionParser.regions("body", json: json)
        comment.summary = RegionParser.regions("summary", json: json)
        // links
        comment.links = data["links"] as? [String: Any]

        return comment
    }

    class func newCommentForPost(_ post: Post, currentUser: User) -> ElloComment {
        let comment = ElloComment(
            id: UUID().uuidString,
            createdAt: Date(),
            authorId: currentUser.id,
            postId: post.id,
            content: [Regionable]()
        )
        return comment
    }
}

extension ElloComment: JSONSaveable {
    var uniqueId: String? { return "ElloComment-\(id)" }
    var tableId: String? { return id }

}
