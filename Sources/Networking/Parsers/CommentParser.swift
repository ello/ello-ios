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
        let createdAt = json["createdAt"].dateValue

        let comment = ElloComment(
            id: json["id"].idValue,
            createdAt: createdAt,
            authorId: json["author"]["id"].idValue,
            postId: json["parentPost"]["id"].idValue,
            content: RegionParser.graphQLRegions(json: json["content"]),
            body: RegionParser.graphQLRegions(json: json["body"]),
            summary: RegionParser.graphQLRegions(json: json["summary"])
        )

        comment.mergeLinks(json["links"].dictionaryObject)

        return comment
    }
}
