////
///  StreamKindSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Moya


class StreamKindSpec: QuickSpec {

    override func spec() {
        describe("StreamKind") {

            // TODO: convert these tests to the looping input/output style used on other enums

            describe("name") {

                it("is correct for all cases") {
                    expect(StreamKind.following.name) == "Following"
                    expect(StreamKind.notifications(category: "").name) == "Notifications"
                    expect(StreamKind.postDetail(postParam: "param").name) == ""
                    expect(StreamKind.simpleStream(endpoint: ElloAPI.searchForPosts(terms: "meat"), title: "meat").name) == "meat"
                    expect(StreamKind.unknown.name) == ""
                    expect(StreamKind.userStream(userParam: "n/a").name) == ""
                }
            }

            describe("cacheKey") {

                it("is correct for all cases") {
                    expect(StreamKind.category(.all, .featured).cacheKey) == "Category"
                    expect(StreamKind.following.cacheKey) == "Following"
                    expect(StreamKind.notifications(category: "").cacheKey) == "Notifications"
                    expect(StreamKind.postDetail(postParam: "param").cacheKey) == "PostDetail"
                    expect(StreamKind.simpleStream(endpoint: ElloAPI.searchForPosts(terms: "meat"), title: "meat").cacheKey) == "SearchForPosts"
                    expect(StreamKind.unknown.cacheKey) == "unknown"
                    expect(StreamKind.userStream(userParam: "NA").cacheKey) == "UserStream"
                }
            }

            describe("lastViewedCreatedAtKey") {

                it("is correct for all cases") {
                    expect(StreamKind.following.lastViewedCreatedAtKey) == "Following_createdAt"
                    expect(StreamKind.notifications(category: "").lastViewedCreatedAtKey) == "Notifications_createdAt"
                    expect(StreamKind.postDetail(postParam: "param").lastViewedCreatedAtKey).to(beNil())
                    expect(StreamKind.unknown.lastViewedCreatedAtKey).to(beNil())
                }
            }

            describe("showsCategory") {
                let expectations: [(StreamKind, Bool)] = [
                    (.manageCategories, false),
                    (.category(.category("art"), .featured), false),
                    (.following, false),
                    (.notifications(category: nil), false),
                    (.notifications(category: "comments"), false),
                    (.postDetail(postParam: "postId"), false),
                    (.userStream(userParam: "userId"), false),
                    (.unknown, false),
                ]
                for (streamKind, expectedValue) in expectations {
                    it("\(streamKind) \(expectedValue ? "can" : "cannot") show category") {
                        expect(streamKind.showsCategory) == expectedValue
                    }
                }
            }

            describe("isProfileStream") {
                let expectations: [(StreamKind, Bool)] = [
                    (.category(.category("art"), .featured), false),
                    (.following, false),
                    (.notifications(category: ""), false),
                    (.postDetail(postParam: "param"), false),
                    (.simpleStream(endpoint: ElloAPI.searchForPosts(terms: "meat"), title: "meat"), false),
                    (.unknown, false),
                    (.userStream(userParam: "NA"), true),
                ]
                for (streamKind, expected) in expectations {
                    it("is \(expected) for \(streamKind)") {
                        expect(streamKind.isProfileStream) == expected
                    }
                }
            }

            describe("endpoint") {

                it("is correct for all cases") {
                    expect(StreamKind.following.endpoint!.path) == "/api/\(ElloAPI.apiVersion)/following/posts/recent"
                    expect(StreamKind.notifications(category: "").endpoint!.path) == "/api/\(ElloAPI.apiVersion)/notifications"
                    expect(StreamKind.postDetail(postParam: "param").endpoint!.path) == "/api/\(ElloAPI.apiVersion)/posts/param"
                    expect(StreamKind.postDetail(postParam: "param").endpoint!.parameters!["comment_count"] as? Int) == 0
                    expect(StreamKind.simpleStream(endpoint: ElloAPI.searchForPosts(terms: "meat"), title: "meat").endpoint!.path) == "/api/\(ElloAPI.apiVersion)/posts"
                    expect(StreamKind.simpleStream(endpoint: ElloAPI.searchForUsers(terms: "meat"), title: "meat").endpoint!.path) == "/api/\(ElloAPI.apiVersion)/users"
                    expect(StreamKind.userStream(userParam: "NA").endpoint!.path) == "/api/\(ElloAPI.apiVersion)/users/NA"
                    expect(StreamKind.unknown.endpoint).to(beNil())
                    expect(StreamKind.userLoves(username: "").endpoint).to(beNil())
                    expect(StreamKind.userFollowing(username: "").endpoint).to(beNil())
                    expect(StreamKind.userFollowers(username: "").endpoint).to(beNil())
                }
            }

            describe("isGridView") {

                beforeEach {
                    StreamKind.category(.category("art"), .featured).setIsGridView(false)
                    StreamKind.following.setIsGridView(false)
                    StreamKind.notifications(category: "").setIsGridView(false)
                    StreamKind.postDetail(postParam: "param").setIsGridView(false)
                    StreamKind.following.setIsGridView(false)
                    StreamKind.simpleStream(endpoint: ElloAPI.searchForPosts(terms: "meat"), title: "meat").setIsGridView(false)
                    StreamKind.unknown.setIsGridView(false)
                    StreamKind.userStream(userParam: "NA").setIsGridView(false)
                }


                it("is correct for all cases") {
                    StreamKind.category(.category("art"), .featured).setIsGridView(true)
                    expect(StreamKind.category(.category("art"), .featured).isGridView) == true

                    StreamKind.category(.category("art"), .featured).setIsGridView(false)
                    expect(StreamKind.category(.category("art"), .featured).isGridView) == false

                    StreamKind.following.setIsGridView(false)
                    expect(StreamKind.following.isGridView) == false

                    StreamKind.following.setIsGridView(true)
                    expect(StreamKind.following.isGridView) == true

                    expect(StreamKind.notifications(category: "").isGridView) == false
                    expect(StreamKind.postDetail(postParam: "param").isGridView) == false

                    StreamKind.simpleStream(endpoint: ElloAPI.searchForPosts(terms: "meat"), title: "meat").setIsGridView(true)
                    expect(StreamKind.simpleStream(endpoint: ElloAPI.searchForPosts(terms: "meat"), title: "meat").isGridView) == true

                    StreamKind.simpleStream(endpoint: ElloAPI.searchForPosts(terms: "meat"), title: "meat").setIsGridView(false)
                    expect(StreamKind.simpleStream(endpoint: ElloAPI.searchForPosts(terms: "meat"), title: "meat").isGridView) == false

                    expect(StreamKind.simpleStream(endpoint: ElloAPI.searchForUsers(terms: "meat"), title: "meat").isGridView) == false
                    expect(StreamKind.unknown.isGridView) == false
                    expect(StreamKind.userStream(userParam: "NA").isGridView) == false
                }
            }

            describe("hasGridViewToggle") {

                it("is correct for all cases") {
                    expect(StreamKind.category(.category("art"), .featured).hasGridViewToggle) == true
                    expect(StreamKind.manageCategories.hasGridViewToggle) == false
                    expect(StreamKind.following.hasGridViewToggle) == true
                    expect(StreamKind.notifications(category: "").hasGridViewToggle) == false
                    expect(StreamKind.postDetail(postParam: "param").hasGridViewToggle) == false
                    expect(StreamKind.simpleStream(endpoint: ElloAPI.searchForPosts(terms: "meat"), title: "meat").hasGridViewToggle) == true
                    expect(StreamKind.simpleStream(endpoint: ElloAPI.searchForUsers(terms: "meat"), title: "meat").hasGridViewToggle) == false
                    expect(StreamKind.unknown.hasGridViewToggle) == false
                    expect(StreamKind.userStream(userParam: "NA").hasGridViewToggle) == false
                }
            }

            describe("isDetail") {

                it("is correct for all cases") {
                    expect(StreamKind.category(.category("art"), .featured).isDetail(post: Post.stub([:]))) == false
                    expect(StreamKind.following.isDetail(post: Post.stub([:]))) == false
                    expect(StreamKind.notifications(category: "").isDetail(post: Post.stub([:]))) == false
                    expect(StreamKind.postDetail(postParam: "~param").isDetail(post: Post.stub(["token": "param"]))) == true
                    expect(StreamKind.postDetail(postParam: "postId").isDetail(post: Post.stub(["id": "postId"]))) == true
                    expect(StreamKind.postDetail(postParam: "wrong").isDetail(post: Post.stub([:]))) == false
                    expect(StreamKind.simpleStream(endpoint: ElloAPI.searchForPosts(terms: "meat"), title: "meat").isDetail(post: Post.stub([:]))) == false
                    expect(StreamKind.simpleStream(endpoint: ElloAPI.searchForUsers(terms: "meat"), title: "meat").isDetail(post: Post.stub([:]))) == false
                    expect(StreamKind.unknown.isDetail(post: Post.stub([:]))) == false
                    expect(StreamKind.userStream(userParam: "NA").isDetail(post: Post.stub([:]))) == false
                }
            }

            describe("supportsLargeImages") {

                it("is correct for all cases") {
                    expect(StreamKind.category(.category("art"), .featured).supportsLargeImages) == false
                    expect(StreamKind.following.supportsLargeImages) == false
                    expect(StreamKind.notifications(category: "").supportsLargeImages) == false
                    expect(StreamKind.postDetail(postParam: "param").supportsLargeImages) == true
                    expect(StreamKind.simpleStream(endpoint: ElloAPI.searchForPosts(terms: "meat"), title: "meat").supportsLargeImages) == false
                    expect(StreamKind.simpleStream(endpoint: ElloAPI.searchForUsers(terms: "meat"), title: "meat").supportsLargeImages) == false
                    expect(StreamKind.unknown.supportsLargeImages) == false
                    expect(StreamKind.userStream(userParam: "NA").supportsLargeImages) == false
                }
            }
        }
    }
}
