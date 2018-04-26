////
///  CategoryPost.swift
//

import SwiftyJSON
import Moya


@objc(CategoryPost)
final class CategoryPost: Model, Groupable {
    static let Version = 1

    let id: String
    var groupId: String { return "CategoryPost-\(id)" }
    let submittedAt: Date?
    let featuredAt: Date?
    let unfeaturedAt: Date?
    let removedAt: Date?
    let status: Status
    var actions: [Action]

    var category: Category? { return getLinkObject("category") }
    var submittedBy: User? { return getLinkObject("submittedBy") }
    var featuredBy: User? { return getLinkObject("featuredBy") }
    var unfeaturedBy: User? { return getLinkObject("unfeaturedBy") }
    var removedBy: User? { return getLinkObject("removedBy") }

    enum Status: String {
        case featured
        case submitted
        case unspecified
    }

    struct Action {
        enum Name: Equatable {
            case feature
            case unfeature
            case other(String)

            static func == (lhs: Name, rhs: Name) -> Bool { return lhs.string == rhs.string }

            init(_ name: String) {
                switch name {
                case "feature": self = .feature
                case "unfeature": self = .unfeature
                default: self = .other(name)
                }
            }

            var string: String {
                switch self {
                case .feature: return "feature"
                case .unfeature: return "unfeature"
                case let .other(string): return string
                }
            }
        }

        let name: Name
        let label: String
        let request: ElloRequest
        var endpoint: ElloAPI { return .customRequest(request, mimics: .categoryPostActions) }

        var order: Int {
            switch name {
            case .feature: return 0
            case .unfeature: return 1
            case .other: return 2
            }
        }

        init(name: Name, label: String, request: ElloRequest) {
            self.name = name
            self.label = label
            self.request = request
        }

        init?(name nameStr: String, json: JSON) {
            guard
                let method = json["method"].string.map({ $0.uppercased() }).flatMap({ Moya.Method(rawValue: $0) }),
                let url = json["href"].string.flatMap({ URL(string: $0) })
            else { return nil }

            let label = json["label"].stringValue
            let parameters = json["body"].object as? [String: Any]
            self.init(name: Name(nameStr), label: label, request: ElloRequest(url: url, method: method, parameters: parameters))
        }
    }

    init(id: String, status: Status, actions: [Action], submittedAt: Date?, featuredAt: Date?, unfeaturedAt: Date?, removedAt: Date?)
    {
        self.id = id
        self.status = status
        self.actions = actions
        self.submittedAt = submittedAt
        self.featuredAt = featuredAt
        self.unfeaturedAt = unfeaturedAt
        self.removedAt = removedAt
        super.init(version: CategoryPost.Version)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        id = decoder.decodeKey("id")
        status = Status(rawValue: decoder.decodeKey("status")) ?? .unspecified
        let actions: [[String: Any]] = decoder.decodeKey("actions")
        let version: Int = decoder.decodeKey("version")
        self.actions = actions.compactMap { Action.decode($0, version: version) }
        submittedAt = decoder.decodeOptionalKey("submittedAt")
        featuredAt = decoder.decodeOptionalKey("featuredAt")
        unfeaturedAt = decoder.decodeOptionalKey("unfeaturedAt")
        removedAt = decoder.decodeOptionalKey("removedAt")
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(status.rawValue, forKey: "status")
        encoder.encodeObject(actions.map { $0.encodeable }, forKey: "actions")
        encoder.encodeObject(submittedAt, forKey: "submittedAt")
        encoder.encodeObject(featuredAt, forKey: "featuredAt")
        encoder.encodeObject(unfeaturedAt, forKey: "unfeaturedAt")
        encoder.encodeObject(removedAt, forKey: "removedAt")
        super.encode(with: coder)
    }

    class func fromJSON(_ data: [String: Any]) -> CategoryPost {
        let json = JSON(data)
        var actions: [CategoryPost.Action] = []
        if let actionsJson = json["actions"].dictionary {
            for (name, actionJson) in actionsJson {
                guard let action = CategoryPost.Action(name: name, json: actionJson) else { continue }
                actions.append(action)
            }
        }

        let submittedAt = json["submitted_at"].stringValue.toDate() ?? Globals.now
        let featuredAt = json["featured_at"].stringValue.toDate() ?? Globals.now
        let unfeaturedAt = json["unfeatured_at"].stringValue.toDate() ?? Globals.now
        let removedAt = json["removed_at"].stringValue.toDate() ?? Globals.now

        let categoryPost = CategoryPost(
            id: json["id"].stringValue,
            status: CategoryPost.Status(rawValue: json["status"].stringValue) ?? .unspecified,
            actions: actions,
            submittedAt: submittedAt,
            featuredAt: featuredAt,
            unfeaturedAt: unfeaturedAt,
            removedAt: removedAt
        )

        categoryPost.mergeLinks(json["links"].dictionaryObject)

        return categoryPost
    }
}

extension CategoryPost {
    func hasAction(_ name: CategoryPost.Action.Name) -> Bool {
        return actions.any { $0.name == name }
    }
}

extension CategoryPost: JSONSaveable {
    var uniqueId: String? { return "CategoryPost-\(id)" }
    var tableId: String? { return id }
}

extension CategoryPost.Action {
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

    static func decode(_ decodeable: [String: Any], version: Int) -> CategoryPost.Action? {
        guard
            let nameStr = decodeable["name"] as? String,
            let label = decodeable["label"] as? String,
            let url = decodeable["url"] as? URL,
            let method = (decodeable["method"] as? String).flatMap({ Moya.Method(rawValue: $0) }),
            let parameters = decodeable["parameters"] as? [String: String]
        else { return nil }

        return CategoryPost.Action(name: Name(nameStr), label: label, request: ElloRequest(url: url, method: method, parameters: parameters))
    }
}
