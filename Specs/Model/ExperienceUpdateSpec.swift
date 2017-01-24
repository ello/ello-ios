////
///  ExperienceUpdateSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ExperienceUpdateSpec: QuickSpec {
    override func spec() {
        describe("ExperienceUpdate") {
            it("should update post comment counts") {
                let post1 = Post.stub(["id": "post1", "commentsCount": 1])
                let post2 = Post.stub(["id": "post2", "commentsCount": 1])
                let comment = ElloComment.stub([
                    "parentPost": post1,
                    "loadedFromPost": post2
                    ])
                ElloLinkedStore.sharedInstance.setObject(post1, forKey: post1.id, type: .postsType)
                ContentChange.updateCommentCount(comment, delta: 1)
                expect(post1.commentsCount) == 2
                expect(post2.commentsCount) == 2
                let storedPost = ElloLinkedStore.sharedInstance.getObject(post1.id, type: .postsType) as! Post
                expect(storedPost.commentsCount) == 2
            }
        }
    }
}
