////
///  CommentSpec.swift
//

@testable import Ello
import Quick
import Nimble

class CommentSpec: QuickSpec {
    override func spec() {
        describe("ElloComment") {
            context("parentPost vs loadedFromPost") {
                it("defaults to parentPost") {
                    let post = Post.stub([:])
                    let comment = ElloComment.stub([
                        "parentPost": post,
                    ])
                    expect(comment.postId) == post.id
                    expect(comment.loadedFromPostId) == post.id
                    expect(comment.parentPost).toNot(beNil())
                    expect(comment.loadedFromPost).toNot(beNil())
                }
                it("can have both") {
                    let post1 = Post.stub([:])
                    let post2 = Post.stub([:])
                    let comment = ElloComment.stub([
                        "parentPost": post1,
                        "loadedFromPost": post2
                    ])
                    expect(comment.postId) == post1.id
                    expect(comment.loadedFromPostId) == post2.id
                    expect(comment.parentPost).toNot(beNil())
                    expect(comment.loadedFromPost).toNot(beNil())
                }
            }
        }
    }
}
