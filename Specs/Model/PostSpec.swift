////
///  PostSpec.swift
//

@testable import Ello
import Quick
import Nimble


class PostSpec: QuickSpec {
    override func spec() {
        describe("Post") {
            beforeEach {
                let testingKeys = APIKeys(
                    key: "",
                    secret: "",
                    segmentKey: "",
                    domain: "https://ello.co",
                    hasGraphQL: false
                )
                APIKeys.shared = testingKeys
            }

            afterEach {
                APIKeys.shared = APIKeys.default
            }

            describe("contentFor(gridView: Bool)") {
                var post: Post!

                beforeEach {
                    post = Post.stub([
                        "content": [TextRegion.stub([:]), TextRegion.stub([:])],
                        "summary": [TextRegion.stub([:])]
                    ])
                }


                it("is correct for list mode") {
                    expect(post.contentFor(gridView: false).count) == 2
                }

                it("is correct for grid mode") {
                    expect(post.contentFor(gridView: true).count) == 1
                }
            }
        }
    }
}
