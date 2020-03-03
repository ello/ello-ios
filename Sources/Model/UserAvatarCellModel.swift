////
///  UserAvatarCellModel.swift
//

let UserAvatarCellModelVersion = 2

@objc(UserAvatarCellModel)
final class UserAvatarCellModel: Model {
    enum EndpointType {
        case lovers
        case reposters
    }

    let endpointType: EndpointType
    var seeMoreTitle: String {
        switch endpointType {
        case .lovers: return InterfaceString.Post.LovedByList
        case .reposters: return InterfaceString.Post.RepostedByList
        }
    }
    var icon: InterfaceImage {
        switch endpointType {
        case .lovers: return .heart
        case .reposters: return .repost
        }
    }
    var endpoint: ElloAPI {
        switch endpointType {
        case .lovers: return .postLovers(postId: postParam)
        case .reposters: return .postReposters(postId: postParam)
        }
    }
    var users: [User] = []
    var postParam: String

    var hasUsers: Bool {
        return users.count > 0
    }

    init(
        type endpointType: EndpointType,
        users: [User],
        postParam: String
    ) {
        self.endpointType = endpointType
        self.users = users
        self.postParam = postParam
        super.init(version: UserAvatarCellModelVersion)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func belongsTo(post: Post, type: EndpointType) -> Bool {
        guard type == endpointType else { return false }
        return post.id == postParam || ("~" + post.token == postParam)
    }

    func append(user: User) {
        guard !users.any({ $0.id == user.id }) else { return }
        users.append(user)
    }

    func remove(user: User) {
        users = users.filter { $0.id != user.id }
    }

}
