////
///  ElloAPISpec.swift
//

@testable import Ello
import Quick
import Moya
import Nimble


class ElloAPISpec: QuickSpec {
    override func spec() {

        describe("convertQueryParams") {
            it("should convert simple query strings") {
                let params = convertQueryParams("a=b")
                expect(params["a"] as? String) == "b"
            }
            it("should convert encoded query strings") {
                let params = convertQueryParams("a%2Ba=b%26b")
                expect(params["a+a"] as? String) == "b&b"
            }
            it("should convert arrays") {
                let params = convertQueryParams("a%5B%5D=1&a%5B%5D=2")
                expect(params["a"] as? [String]) == ["1", "2"]
            }
        }

        describe("ElloAPI") {

            describe("pagingPaths") {
                context("are valid") {
                    let expectations: [(ElloAPI, String)] = [
                        (.category(slug: "art"), "/api/v2/categories/art/posts/recent"),
                        (.postDetail(postParam: "some-param"), "/api/v2/posts/some-param/comments"),
                        (.userStream(userParam: "999"), "/api/v2/users/999/posts"),
                        ]
                    for (api, pagingPath) in expectations {
                        it("\(api).pagingPath is valid") {
                            expect(api.pagingPath) == pagingPath
                        }
                    }
                }
            }

            describe("headers") {
                let expectedBuildNumber = Bundle.main.infoDictionary![kCFBundleVersionKey as String] as! String
                let date = Globals.now
                let endpoints: [ElloAPI] = [
                    .followingNewContent(createdAt: date),
                    .notificationsNewContent(createdAt: date)
                ]
                for endpoint in endpoints {
                    it("\(endpoint) has the correct headers") {
                        expect(endpoint.headers!["Accept-Language"]) == ""
                        expect(endpoint.headers!["Accept"]) == "application/json"
                        expect(endpoint.headers!["Content-Type"]) == "application/json"
                        expect(endpoint.headers!["If-Modified-Since"]) == date.toHTTPDateString()
                        expect(endpoint.headers!["X-iOS-Build-Number"]) == expectedBuildNumber
                        expect(endpoint.headers!["X-iOS-Build-Number"]).to(match("^\\d+$"))
                        expect(endpoint.headers!["Authorization"]) == AuthToken().tokenWithBearer ?? ""
                    }
                }

            }

            describe("parameter values") {

                it("anonymousCredentials") {
                    let params = ElloAPI.anonymousCredentials.parameters!
                    expect(params["client_id"]).notTo(beNil())
                    expect(params["client_secret"]).notTo(beNil())
                    expect(params["grant_type"] as? String) == "client_credentials"
                }

                it("auth") {
                    let params = ElloAPI.auth(email: "me@me.me", password: "p455w0rd").parameters!
                    expect(params["client_id"]).notTo(beNil())
                    expect(params["client_secret"]).notTo(beNil())
                    expect(params["email"] as? String) == "me@me.me"
                    expect(params["password"] as? String) == "p455w0rd"
                    expect(params["grant_type"] as? String) == "password"
                }

                it("availability") {
                    let content = ["username": "sterlingarcher"]
                    expect(ElloAPI.availability(content: content).parameters as? [String: String]) == content
                }

                it("createComment") {
                    let content = ["text": "my sweet comment content"]
                    expect(ElloAPI.createComment(parentPostId: "id", body: content as [String: Any]).parameters as? [String: String]) == content
                }

                it("createPost") {
                    let content = ["text": "my sweet post content"]
                    expect(ElloAPI.createPost(body: content as [String: Any]).parameters as? [String: String]) == content
                }

                it("categoryPosts") {
                    let params = ElloAPI.categoryPosts(slug: "art").parameters!
                    expect(params["per_page"] as? Int) == 10
                }

                it("following") {
                    let params = ElloAPI.following.parameters!
                    expect(params["per_page"] as? Int) == 10
                }

                it("infiniteScroll") {
                    let query = URLComponents(string: "ttp://ello.co/api/v2/posts/278/comments?after=2014-06-02T00%3A00%3A00.000000000%2B0000&per_page=2")!
                    let infiniteScroll: ElloAPI = .infiniteScroll(query: query, api: .editorials)
                    let params = infiniteScroll.parameters!
                    expect(params["per_page"] as? String) == "2"
                    expect(params["after"]).notTo(beNil())
                }

                it("invitations") {
                    let params = ElloAPI.invitations(emails: ["me@me.me"]).parameters!
                    expect(params["email"] as? [String]) == ["me@me.me"]
                }

                it("inviteFriends") {
                    let params = ElloAPI.inviteFriends(email: "me@me.me").parameters!
                    expect(params["email"] as? String) == "me@me.me"
                }

                describe("Join") {
                    context("without an invitation code") {
                        let params = ElloAPI.join(email: "me@me.me", username: "sweetness", password: "password", invitationCode: nil).parameters!
                        expect(params["email"] as? String) == "me@me.me"
                        expect(params["username"] as? String) == "sweetness"
                        expect(params["password"] as? String) == "password"
                        expect(params["invitation_code"]).to(beNil())
                    }

                    context("with an invitation code") {
                        let params = ElloAPI.join(email: "me@me.me", username: "sweetness", password: "password", invitationCode: "my-sweet-code").parameters!
                        expect(params["email"] as? String) == "me@me.me"
                        expect(params["username"] as? String) == "sweetness"
                        expect(params["password"] as? String) == "password"
                        expect(params["invitation_code"] as? String) == "my-sweet-code"
                    }
                }


                describe("NotificationsStream") {

                    it("without a category") {
                        let params = ElloAPI.notificationsStream(category: nil).parameters!
                        expect(params["per_page"] as? Int) == 10
                        expect(params["category"]).to(beNil())
                    }

                    it("with a category") {
                        let params = ElloAPI.notificationsStream(category: "all").parameters!
                        expect(params["per_page"] as? Int) == 10
                        expect(params["category"] as? String) == "all"
                    }
                }

                it("postComments") {
                    let params = ElloAPI.postComments(postId: "comments-id").parameters!
                    expect(params["per_page"] as? Int) == 10
                }

                describe("postViews endpoint") {
                    it("with email") {
                        let params = ElloAPI.postViews(streamId: "123", streamKind: "post", postIds: Set(["555"]), currentUserId: "666").parameters!
                        expect(params["post_ids"] as? String) == "555"
                        expect(params["user_id"] as? String) == "666"
                        expect(params["kind"] as? String) == "post"
                        expect(params["id"] as? String) == "123"
                    }
                    it("with no streamId") {
                        let params = ElloAPI.postViews(streamId: nil, streamKind: "post", postIds: Set(["555"]), currentUserId: "666").parameters!
                        expect(params["post_ids"] as? String) == "555"
                        expect(params["user_id"] as? String) == "666"
                        expect(params["kind"] as? String) == "post"
                        expect(params["id"]).to(beNil())
                    }
                    it("with many posts") {
                        let params = ElloAPI.postViews(streamId: "123", streamKind: "post", postIds: Set(["555", "777"]), currentUserId: "666").parameters!
                        expect(params["post_ids"] as? String).to(satisfyAnyOf(equal("555,777"), equal("777,555")))
                        expect(params["user_id"] as? String) == "666"
                        expect(params["kind"] as? String) == "post"
                        expect(params["id"] as? String) == "123"
                    }
                    it("anonymous") {
                        let params = ElloAPI.postViews(streamId: "123", streamKind: "post", postIds: Set(["555"]), currentUserId: nil).parameters!
                        expect(params["post_ids"] as? String) == "555"
                        expect(params["user_id"] as? String).to(beNil())
                        expect(params["kind"] as? String) == "post"
                        expect(params["id"] as? String) == "123"
                    }
                }

                it("reAuth") {
                    let params = ElloAPI.reAuth(token: "refresh").parameters!
                    expect(params["client_id"]).notTo(beNil())
                    expect(params["client_secret"]).notTo(beNil())
                    expect(params["grant_type"] as? String) == "refresh_token"
                    expect(params["refresh_token"] as? String) == "refresh"
                }

                it("relationshipBatch") {
                    let params = ElloAPI.relationshipBatch(userIds: ["1", "2", "8"], relationship: "friend").parameters!
                    expect(params["user_ids"] as? [String]) == ["1", "2", "8"]
                    expect(params["priority"] as? String) == "friend"
                }

                it("rePost") {
                    let params = ElloAPI.rePost(postId: "666").parameters!
                    expect(params["repost_id"] as? Int) == 666
                }

                it("searchForPosts") {
                    let params = ElloAPI.searchForPosts(terms: "blah").parameters!
                    expect(params["terms"] as? String) == "blah"
                    expect(params["per_page"] as? Int) == 10
                }

                it("searchForUsers") {
                    let params = ElloAPI.searchForUsers(terms: "blah").parameters!
                    expect(params["terms"] as? String) == "blah"
                    expect(params["per_page"] as? Int) == 10
                }

                it("userNameAutoComplete") {
                    let params = ElloAPI.userNameAutoComplete(terms: "blah").parameters!
                    expect(params["terms"] as? String) == "blah"
                }

                it("userCategories") {
                    let params = ElloAPI.userCategories(categoryIds: ["456"], onboarding: false).parameters!
                    expect(params["followed_category_ids"] as? [String]) == ["456"]
                    expect(params["disable_follows"] as? Bool) == true
                }
            }
        }
    }
}
