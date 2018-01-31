////
///  CommentParser.swift
//

import SwiftyJSON


class CommentParser: IdParser {

    init() {
        super.init(table: .commentsType)
        linkArray(.assetsType)
        linkObject(.usersType, "author")
        linkObject(.categoriesType)
        linkObject(.artistInviteSubmissionsType)
    }

    override func parse(json: JSON) -> ElloComment {
        let createdAt = json["created_at"].stringValue.toDate() ?? Globals.now

        let comment = ElloComment(
            id: json["id"].stringValue,
            createdAt: createdAt,
            authorId: json["author_id"].stringValue,
            postId: json["post_id"].stringValue,
            content: RegionParser.graphQLRegions(json: json["content"])
        )

        comment.body = RegionParser.graphQLRegions(json: json["body"])
        comment.summary = RegionParser.graphQLRegions(json: json["summary"])
        comment.links = json["links"].dictionaryObject

        return comment
    }
}
