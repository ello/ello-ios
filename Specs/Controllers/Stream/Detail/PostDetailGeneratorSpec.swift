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
            let streamKind: StreamKind = .userStream(userParam: currentUser.id)
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

                StubbedManager.current.addStub(endpointName: "commentStream")
            }

            describe("load()") {

                beforeEach {
                    subject.load()
                }

                it("sets placeholders") {
                    expect(destination.placeholderItems.count) == 8
                }

                it("replaces the appropriate placeholders") {
                    expect(destination.headerItems.count) > 0
                    expect(destination.postLoverItems.count) > 0
                    expect(destination.postReposterItems.count) > 0
                    expect(destination.postCommentItems.count) > 0
                    expect(destination.postLoadCommentItems.count) > 0
                    expect(destination.postSocialPaddingItems.count) > 0
                    expect(destination.postCommentBarItems.count) > 0
                    expect(destination.postRelatedPostsItems.count) > 0
                    expect(destination.otherPlaceHolderLoaded) == false
                }

                it("sets the primary jsonable") {
                    expect(destination.post).toNot(beNil())
                    expect(destination.post?.id) == "123"
                }

                it("can load more comments") {
                    let prevCount = destination.postCommentItems.count
                    StubbedManager.current.addStub(endpointName: "commentStream")
                    subject.loadMoreComments()
                    expect(destination.postCommentItems.count) > prevCount
                    expect(destination.otherPlaceHolderLoaded) == false
                }

                it("can stop loading comments") {
                    expect(destination.postLoadCommentItems.count) > 0
                    StubbedManager.current.addStub(endpointName: "commentStream-last")
                    subject.loadMoreComments()
                    expect(destination.postLoadCommentItems.count) == 0
                }
            }
        }
    }
}

class PostDetailDestination: PostDetailStreamDestination {

    var placeholderItems: [StreamCellItem] = []
    var headerItems: [StreamCellItem] = []
    var postLoverItems: [StreamCellItem] = []
    var postReposterItems: [StreamCellItem] = []
    var postCommentItems: [StreamCellItem] = []
    var postLoadCommentItems: [StreamCellItem] = []
    var postSocialPaddingItems: [StreamCellItem] = []
    var postCommentBarItems: [StreamCellItem] = []
    var postRelatedPostsItems: [StreamCellItem] = []
    var otherPlaceHolderLoaded = false
    var post: Post?
    var responseConfig: ResponseConfig?
    var isPagingEnabled: Bool = false

    func setPlaceholders(items: [StreamCellItem]) {
        placeholderItems = items
    }

    func replacePlaceholder(type: StreamCellType.PlaceholderType, items: [StreamCellItem], completion: @escaping Block) {
        switch type {
        case .postHeader:
            headerItems = items
        case .postLovers:
            postLoverItems = items
        case .postReposters:
            postReposterItems = items
        case .postComments:
            postCommentItems = items
        case .postLoadingComments:
            postLoadCommentItems = items
        case .postSocialPadding:
            postSocialPaddingItems = items
        case .postCommentBar:
            postCommentBarItems = items
        case .postRelatedPosts:
            postRelatedPostsItems = items
        default:
            otherPlaceHolderLoaded = true
        }
    }

    func setPrimary(jsonable: Model) {
        guard let post = jsonable as? Post else { return }
        self.post = post
    }

    func primaryModelNotFound() {
    }

    func setPagingConfig(responseConfig: ResponseConfig) {
        self.responseConfig = responseConfig
    }

    func appendComments(_ items: [StreamCellItem]) {
        postCommentItems += items
    }
}
