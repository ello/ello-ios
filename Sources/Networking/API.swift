////
///  ElloGraphQL.swift
//

import Alamofire
import PromiseKit
import SwiftyJSON


struct API {
    static var sharedManager: RequestManager = ElloManager()

    enum PageHeaderKind {
        case category(String)
        case artistInvites
        case editorials
        case generic

        var apiKind: String {
            switch self {
            case .category: return "CATEGORY"
            case .editorials: return "EDITORIAL"
            case .artistInvites: return "ARTIST_INVITE"
            case .generic: return "GENERIC"
            }
        }

        var slug: String? {
            switch self {
            case let .category(slug): return slug
            default: return nil
            }
        }
    }

    func globalPostStream(filter: CategoryFilter, before: String? = nil) -> GraphQLRequest<(PageConfig, [Post])> {
        let request = GraphQLRequest(
            endpointName: "globalPostStream",
            parser: PageParser<Post>("posts", PostParser()).parse,
            variables: [
                (.enum("kind", "StreamKind", filter.graphQL)),
                (.optionalString("before", before)),
            ],
            fragments: [Fragment.postStream],
            body: Fragment.postStreamBody
            )
        return request
    }

    func categoryPostStream(categorySlug: String, filter: CategoryFilter, before: String? = nil) -> GraphQLRequest<(PageConfig, [Post])> {
        let request = GraphQLRequest(
            endpointName: "categoryPostStream",
            parser: PageParser<Post>("posts", PostParser()).parse,
            variables: [
                (.enum("kind", "StreamKind", filter.graphQL)),
                (.string("slug", categorySlug)),
                (.optionalString("before", before)),
            ],
            fragments: [Fragment.postStream],
            body: Fragment.postStreamBody
            )
        return request
    }

    func subscribedPostStream(filter: CategoryFilter, before: String? = nil) -> GraphQLRequest<(PageConfig, [Post])> {
        let request = GraphQLRequest(
            endpointName: "subscribedPostStream",
            parser: PageParser<Post>("posts", PostParser()).parse,
            variables: [
                (.enum("kind", "StreamKind", filter.graphQL)),
                (.optionalString("before", before)),
            ],
            fragments: [Fragment.postStream],
            body: Fragment.postStreamBody
            )
        return request
    }

    func allCategories() -> GraphQLRequest<[Category]> {
        let request = GraphQLRequest(
            endpointName: "allCategories",
            parser: ManyParser<Category>(CategoryParser()).parse,
            fragments: [
                Fragment.tshirtProps,
            ],
            body: Fragment.categoriesBody
            )
        return request
    }

    func subscribedCategories() -> GraphQLRequest<[Category]> {
        let request = GraphQLRequest(
            endpointName: "categoryNav",
            parser: ManyParser<Category>(CategoryParser()).parse,
            fragments: [
                Fragment.tshirtProps,
            ],
            body: Fragment.categoriesBody
            )
        return request
    }

    func pageHeaders(kind: PageHeaderKind) -> GraphQLRequest<[PageHeader]> {
        let request = GraphQLRequest(
            endpointName: "pageHeaders",
            parser: ManyParser<PageHeader>(PageHeaderParser()).parse,
            variables: [
                (.enum("kind", "PageHeaderKind", kind.apiKind)),
                (.optionalString("slug", kind.slug)),
            ],
            fragments: [
                Fragment.responsiveProps,
                Fragment.pageHeaderUserProps,
            ],
            body: Fragment.pageHeaderBody
            )
        return request
    }

    func userPosts(username: String, before: String? = nil) -> GraphQLRequest<(PageConfig, [Post])> {
        let request = GraphQLRequest(
            endpointName: "userPostStream",
            parser: PageParser<Post>("posts", PostParser()).parse,
            variables: [
                (.string("username", username)),
                (.optionalString("before", before)),
            ],
            fragments: [Fragment.postStream],
            body: Fragment.postStreamBody
            )
        return request
    }
}
