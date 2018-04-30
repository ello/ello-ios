////
///  ArtistInviteSubmission.swift
//

import SwiftyJSON
import Moya


@objc(ArtistInviteSubmission)
final class ArtistInviteSubmission: Model, Groupable, PostActionable {
    // Version 1: initial
    // Version 2: artistInviteId, postId
    static let Version = 2

    let id: String
    var groupId: String { return "ArtistInviteSubmission-\(id)" }
    let artistInviteId: String
    let postId: String
    let status: Status
    var actions: [Action] = []

    var artistInvite: ArtistInvite? { return getLinkObject("artist_invite") }
    var post: Post? { return getLinkObject("post") }
    var user: User? { return post?.author }

    enum Status: String {
        case approved
        case selected
        case unapproved
        case unspecified
        case declined
    }

    struct Action {
        enum Name {
            case approve
            case unapprove
            case select
            case unselect
            case decline
            case other(String)

            init(_ name: String) {
                switch name {
                case "unapprove": self = .unapprove
                case "unselect": self = .unselect
                case "approve": self = .approve
                case "select": self = .select
                case "decline": self = .decline
                default: self = .other(name)
                }
            }

            var string: String {
                switch self {
                case .unapprove: return "unapprove"
                case .unselect: return "unselect"
                case .approve: return "approve"
                case .select: return "select"
                case .decline: return "decline"
                case let .other(string): return string
                }
            }
        }

        let name: Name
        let label: String
        let request: ElloRequest
        var endpoint: ElloAPI { return .customRequest(request, mimics: .artistInviteSubmissions) }

        var order: Int {
            switch name {
            case .unapprove: return 0
            case .approve: return 1
            case .unselect: return 2
            case .select: return 3
            case .decline: return 4
            case .other: return 5
            }
        }

        init(name: Name, label: String, request: ElloRequest) {
            self.name = name
            self.label = label
            self.request = request
        }

        init?(name nameStr: String, json: JSON) {
            guard
                let parameters = json["body"].object as? [String: Any],
                let label = json["label"].string,
                let method = json["method"].string.map({ $0.uppercased() }).flatMap({ Moya.Method(rawValue: $0) }),
                let url = json["href"].string.flatMap({ URL(string: $0) })
            else { return nil }

            self.init(name: Name(nameStr), label: label, request: ElloRequest(url: url, method: method, parameters: parameters))
        }
    }

    init(id: String, artistInviteId: String, postId: String, status: Status) {
        self.id = id
        self.artistInviteId = artistInviteId
        self.postId = postId
        self.status = status
        super.init(version: ArtistInviteSubmission.Version)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        let version: Int = decoder.decodeKey("version")
        id = decoder.decodeKey("id")
        if version > 1 {
            artistInviteId = decoder.decodeKey("artistInviteId")
            postId = decoder.decodeKey("postId")
        }
        else {
            artistInviteId = ""
            postId = ""
        }
        status = Status(rawValue: decoder.decodeKey("status") as String) ?? .unspecified
        let actions: [[String: Any]] = decoder.decodeKey("actions")
        self.actions = actions.compactMap { Action.decode($0, version: version) }
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(artistInviteId, forKey: "artistInviteId")
        encoder.encodeObject(postId, forKey: "postId")
        encoder.encodeObject(status.rawValue, forKey: "status")
        encoder.encodeObject(actions.map { $0.encodeable }, forKey: "actions")
        super.encode(with: coder)
    }

    class func fromJSON(_ data: [String: Any]) -> ArtistInviteSubmission {
        let json = JSON(data)

        let id = json["id"].stringValue
        let artistInviteId = json["artist_invite_id"].stringValue
        let postId: String
        if let v1 = json["post_id"].id {
            postId = v1
        }
        else if let v2 = json["links"]["post"]["id"].id {
            postId = v2
        }
        else {
            postId = ""
        }
        let status = Status(rawValue: json["status"].stringValue) ?? .unapproved
        let submission = ArtistInviteSubmission(id: id, artistInviteId: artistInviteId, postId: postId, status: status)
        submission.mergeLinks(data["links"] as? [String: Any])
        submission.addLinkObject("artist_invite", id: artistInviteId, type: .artistInvitesType)

        if let actions = data["actions"] as? [String: Any] {
            submission.actions = actions.compactMap { key, value in
                return Action(name: key, json: JSON(value))
            }.sorted { a, b in
                return a.order < b.order
            }
        }

        return submission
    }
}

extension ArtistInviteSubmission: JSONSaveable {
    var uniqueId: String? { return "ArtistInviteSubmission-\(id)" }
    var tableId: String? { return id }
}

extension ArtistInviteSubmission.Action {
    var encodeable: [String: Any] {
        let parameters: [String: Any] = request.parameters ?? [:]
        return [
            "name": name.string,
            "label": label,
            "url": request.url,
            "method": request.method.rawValue,
            "parameters": parameters,
        ]
    }

    static func decode(_ decodeable: [String: Any], version: Int) -> ArtistInviteSubmission.Action? {
        guard
            let nameStr = decodeable["name"] as? String,
            let label = decodeable["label"] as? String,
            let url = decodeable["url"] as? URL,
            let method = (decodeable["method"] as? String).flatMap({ Moya.Method(rawValue: $0) }),
            let parameters = decodeable["parameters"] as? [String: String]
        else { return nil }

        return ArtistInviteSubmission.Action(name: Name(nameStr), label: label, request: ElloRequest(url: url, method: method, parameters: parameters))
    }
}
