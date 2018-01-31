////
///  PostParser.swift
//

import SwiftyJSON


class PostParser: IdParser {

    init() {
        super.init(table: .postsType)
        linkArray(.assetsType)
        linkObject(.usersType, "author")
        linkObject(.categoriesType)
        linkObject(.artistInviteSubmissionsType)
    }

    override func parse(json: JSON) -> Post {
        let repostContent = RegionParser.graphQLRegions(json: json["repostContent"])
        let createdAt = json["created_at"].stringValue.toDate() ?? Globals.now

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
