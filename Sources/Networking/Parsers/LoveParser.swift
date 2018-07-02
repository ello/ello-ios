////
///  LoveParser.swift
//

import SwiftyJSON


class LoveParser: IdParser {

    init() {
        super.init(table: .lovesType)
        linkObject(.postsType, "post")
        linkObject(.usersType, "user")
    }

    override func parse(json: JSON) -> Love {
        let love = Love(
            id: json["id"].idValue,
            isDeleted: json["deleted"].boolValue,
            postId: json["post"]["id"].idValue,
            userId: json["user"]["id"].idValue
        )

        love.mergeLinks(json["links"].dictionaryObject)

        return love
    }
}
