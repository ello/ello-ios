////
///  PostDetailGeneratorSpec.swift
//

@testable import Ello
import Quick
import Nimble

class PostDetailGeneratorSpec: QuickSpec {
    override func spec() {
        describe("PostDetailGenerator") {
            let currentUser: User = stub(["id": "42"])
            let post: Post = stub([
                "id": "123",
                "content": [TextRegion.stub([:])]
                ])
            let streamKind: StreamKind = .currentUserStream
            var destination: PostDetailDestination!
            var subject: PostDetailGenerator!

            beforeEach {
                destination = PostDetailDestination()
                subject = PostDetailGenerator(
                    currentUser: currentUser,
                    postParam: "123",
                    post: post,
                    streamKind: streamKind,
                    destination: destination
                )
            }

            describe("load()") {

                beforeEach {
                    subject.load()
                }

                it("sets placeholders") {
                    expect(destination.placeholderItems.count) == 6
                }

                it("replaces the appropriate placeholders") {
                    expect(destination.headerItems.count) > 0
                    expect(destination.postLoverItems.count) > 0
                    expect(destination.postReposterItems.count) > 0
                    expect(destination.postCommentItems.count) > 0
                    expect(destination.postSocialPaddingItems.count) > 0
                    expect(destination.postCommentBarItems.count) > 0
                    expect(destination.otherPlaceHolderLoaded) == false
                }

                it("sets the primary jsonable") {
                    expect(destination.post).toNot(beNil())
                    expect(destination.post?.id) == "123"
                }

                it("sets the config response") {
                    expect(destination.responseConfig).toNot(beNil())
                }
            }
        }
    }
}

class PostDetailDestination: StreamDestination {

    var placeholderItems: [StreamCellItem] = []
    var headerItems: [StreamCellItem] = []
    var postLoverItems: [StreamCellItem] = []
    var postReposterItems: [StreamCellItem] = []
    var postCommentItems: [StreamCellItem] = []
    var postSocialPaddingItems: [StreamCellItem] = []
    var postCommentBarItems: [StreamCellItem] = []
    var otherPlaceHolderLoaded = false
    var post: Post?
    var responseConfig: ResponseConfig?
    var pagingEnabled: Bool = false

    func reset() {
        placeholderItems = []
        headerItems = []
        postLoverItems = []
        postReposterItems = []
        postCommentItems = []
        postSocialPaddingItems = []
        postCommentBarItems = []
        otherPlaceHolderLoaded = false
        post = nil
        responseConfig = nil
    }

    func setPlaceholders(items: [StreamCellItem]) {
        placeholderItems = items
    }

    func replacePlaceholder(type: StreamCellType.PlaceholderType, items: [StreamCellItem], completion: @escaping ElloEmptyCompletion) {
        switch type {
        case .postHeader:
            headerItems = items
        case .postLovers:
            postLoverItems = items
        case .postReposters:
            postReposterItems = items
        case .postComments:
            postCommentItems = items
        case .postSocialPadding:
            postSocialPaddingItems = items
        case .postCommentBar:
            postCommentBarItems = items
        default:
            otherPlaceHolderLoaded = true
        }
    }

    func setPrimary(jsonable: JSONAble) {
        guard let post = jsonable as? Post else { return }
        self.post = post
    }

    func primaryJSONAbleNotFound() {
    }

    func setPagingConfig(responseConfig: ResponseConfig) {
        self.responseConfig = responseConfig
    }
}
