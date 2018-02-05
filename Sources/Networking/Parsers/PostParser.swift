////
///  PostParser.swift
//

import SwiftyJSON


class PostParser: IdParser {

    init() {
        super.init(table: .postsType)
        linkArray(.assetsType)
        linkObject(.usersType, "author")
        linkObject(.usersType, "repostAuthor")
        linkObject(.postsType, "repostedSource")
        linkObject(.categoriesType)
        linkObject(.artistInviteSubmissionsType)
    }

    override func flatten(json _json: JSON, identifier: Identifier, db: inout Database) {
        var json = _json
        let repostedSource = json["repostedSource"]
        if let repostIdentifier = self.identifier(json: repostedSource) {
            flatten(json: repostedSource, identifier: repostIdentifier, db: &db)
            json["links"] = ["reposted_source": ["id": repostIdentifier.id, "type": MappingType.postsType.rawValue]]
        }

        super.flatten(json: json, identifier: identifier, db: &db)
    }

    override func parse(json: JSON) -> Post {
        let repostContent = RegionParser.graphQLRegions(json: json["repostContent"])
        let createdAt = json["createdAt"].stringValue.toDate() ?? Globals.now

        let post = Post(
            id: json["id"].stringValue,
            createdAt: createdAt,
            authorId: json["author"]["id"].stringValue,
            token: json["token"].stringValue,
            isAdultContent: false, // json["is_adult_content"].boolValue,
            contentWarning: "", // json["content_warning"].stringValue,
            allowComments: true, // json["allow_comments"].boolValue,
            isReposted: json["currentUserState"]["reposted"].bool ?? false,
            isLoved: json["currentUserState"]["loved"].bool ?? false,
            isWatching: json["currentUserState"]["watching"].bool ?? false,
            summary: RegionParser.graphQLRegions(json: json["summary"])
        )

        post.content = RegionParser.graphQLRegions(json: json["content"], isRepostContent: repostContent.count > 0)
        post.body = RegionParser.graphQLRegions(json: json["body"], isRepostContent: repostContent.count > 0)
        post.repostContent = repostContent
        // post.artistInviteId = json["artist_invite_id"].string

        post.viewsCount = json["postStats"]["viewsCount"].int
        post.commentsCount = json["postStats"]["commentsCount"].int
        post.repostsCount = json["postStats"]["repostsCount"].int
        post.lovesCount = json["postStats"]["lovesCount"].int

        post.links = json["links"].dictionaryObject

        return post
    }
}
