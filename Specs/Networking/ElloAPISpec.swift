////
///  ElloAPISpec.swift
//

@testable import Ello
import Quick
import Moya
import Nimble


class ElloAPISpec: QuickSpec {
    override func spec() {

        var provider: MoyaProvider<ElloAPI>!

        beforeEach {
            provider = ElloProvider.StubbingProvider()
        }

        afterEach {
            provider = ElloProvider.DefaultProvider()
        }

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
            describe("paths") {

                context("are valid") {
                    let expectations: [(ElloAPI, String)] = [
                        (.amazonCredentials, "/api/v2/assets/credentials"),
                        (.announcements, "/api/v2/most_recent_announcements"),
                        (.announcementsNewContent(createdAt: nil), "/api/v2/most_recent_announcements"),
                        (.anonymousCredentials, "/api/oauth/token"),
                        (.auth(email: "", password: ""), "/api/oauth/token"),
                        (.availability(content: [:]), "/api/v2/availability"),
                        (.categories, "/api/v2/categories"),
                        (.category(slug: "art"), "/api/v2/categories/art"),
                        (.categoryPosts(slug: "art"), "/api/v2/categories/art/posts/recent"),
                        (.collaborate(userId: "666", body: "foo"), "/api/v2/users/666/collaborate"),
                        (.commentDetail(postId: "1", commentId: "2"), "/api/v2/posts/1/comments/2"),
                        (.createComment(parentPostId: "1", body: [:]), "/api/v2/posts/1/comments"),
                        (.createLove(postId: "1"), "/api/v2/posts/1/loves"),
                        (.createPost(body: [:]), "/api/v2/posts"),
                        (.createWatchPost(postId: "1"), "/api/v2/posts/1/watches"),
                        (.currentUserBlockedList, "/api/v2/profile/blocked"),
                        (.currentUserMutedList, "/api/v2/profile/muted"),
                        (.currentUserProfile, "/api/v2/profile"),
                        (.deleteComment(postId: "666", commentId: "777"), "/api/v2/posts/666/comments/777"),
                        (.deleteLove(postId: "1"), "/api/v2/posts/1/love"),
                        (.deletePost(postId: "666"), "/api/v2/posts/666"),
                        (.deleteSubscriptions(token: Data(base64Encoded: "Zm9v")!), "/api/v2/profile/push_subscriptions/apns/666f6f"),  // Zm9v is base64 of "foo", btw
                        (.deleteWatchPost(postId: "1"), "/api/v2/posts/1/watch"),
                        (.discover(type: .featured), "/api/v2/categories/posts/recent"),
                        (.discover(type: .recent), "/api/v2/discover/posts/recent"),
                        (.discover(type: .trending), "/api/v2/discover/posts/trending"),
                        (.emojiAutoComplete(terms: ""), "/api/v2/emoji/autocomplete"),
                        (.findFriends(contacts: [:]), "/api/v2/profile/find_friends"),
                        (.flagComment(postId: "555", commentId: "666", kind: "some-string"), "/api/v2/posts/555/comments/666/flag/some-string"),
                        (.flagPost(postId: "456", kind: "another-kind"), "/api/v2/posts/456/flag/another-kind"),
                        (.flagUser(userId: "666", kind: "any"), "/api/v2/users/666/flag/any"),
                        (.followingNewContent(createdAt: nil), "/api/v2/following/posts/recent"),
                        (.following, "/api/v2/following/posts/recent"),
                        (.hire(userId: "666", body: "foo"), "/api/v2/users/666/hire_me"),
                        (.infiniteScroll(query: URLComponents(string: "/api/v2/following/posts/recent")!, api: .following), "/api/v2/following/posts/recent"),
                        (.invitations(emails: ["someContact"]), "/api/v2/invitations"),
                        (.inviteFriends(email: "someContact"), "/api/v2/invitations"),
                        (.join(email: "", username: "", password: "", invitationCode: nil), "/api/v2/join"),
                        (.locationAutoComplete(terms: ""), "/api/v2/profile/location_autocomplete"),
                        (.loves(userId: "666"), "/api/v2/users/666/loves"),
                        (.notificationsNewContent(createdAt: nil), "/api/v2/notifications"),
                        (.markAnnouncementAsRead, "/api/v2/most_recent_announcements/mark_last_read_announcement"),
                        (.notificationsStream(category: nil), "/api/v2/notifications"),
                        (.pagePromotionals, "/api/v2/page_promotionals"),
                        (.postComments(postId: "fake-id"), "/api/v2/posts/fake-id/comments"),
                        (.postDetail(postParam: "some-param"), "/api/v2/posts/some-param"),
                        (.postViews(streamId: "", streamKind: "", postIds: Set<String>(), currentUserId: ""), "/api/v2/post_views"),
                        (.postLovers(postId: "1"), "/api/v2/posts/1/lovers"),
                        (.postReplyAll(postId: "1"), "/api/v2/posts/1/commenters_usernames"),
                        (.postReposters(postId: "1"), "/api/v2/posts/1/reposters"),
                        (.profileDelete, "/api/v2/profile"),
                        (.profileToggles, "/api/v2/profile/settings"),
                        (.profileUpdate(body: [:]), "/api/v2/profile"),
                        (.pushSubscriptions(token: Data(base64Encoded: "Zm9v")!), "/api/v2/profile/push_subscriptions/apns/666f6f"),
                        (.reAuth(token: ""), "/api/oauth/token"),
                        (.relationship(userId: "1234", relationship: "friend"), "/api/v2/users/1234/add/friend"),
                        (.relationshipBatch(userIds: [], relationship: "friend"), "/api/v2/relationships/batches"),
                        (.rePost(postId: "1"), "/api/v2/posts"),
                        (.searchForPosts(terms: ""), "/api/v2/posts"),
                        (.searchForUsers(terms: ""), "/api/v2/users"),
                        (.updateComment(postId: "1", commentId: "2", body: [:]), "/api/v2/posts/1/comments/2"),
                        (.updatePost(postId: "1", body: [:]), "/api/v2/posts/1"),
                        (.userCategories(categoryIds: ["1"]), "/api/v2/profile/followed_categories"),
                        (.userNameAutoComplete(terms: ""), "/api/v2/users/autocomplete"),
                        (.userStream(userParam: "999"), "/api/v2/users/999"),
                        (.userStreamFollowers(userId: "321"), "/api/v2/users/321/followers"),
                        (.userStreamFollowing(userId: "123"), "/api/v2/users/123/following"),
                        (.userStreamPosts(userId: "666"), "/api/v2/users/666/posts"),
                        ]
                    for (api, path) in expectations {
                        it("\(api).path is valid") {
                            expect(api.path) == path
                        }
                    }
                }
            }

            describe("mappingType") {

                let currentUserId = "123"

                let expectations: [(ElloAPI, MappingType)] = [
                    (.amazonCredentials, .amazonCredentialsType),
                    (.anonymousCredentials, .noContentType),
                    (.auth(email: "", password: ""), .noContentType),
                    (.availability(content: ["":""]), .availabilityType),
                    (.commentDetail(postId: "", commentId: ""), .commentsType),
                    (.categories, .categoriesType),
                    (.createComment(parentPostId: "", body: ["": ""]), .commentsType),
                    (.createLove(postId: ""), .lovesType),
                    (.createPost(body: ["": ""]), .postsType),
                    (.currentUserProfile, .usersType),
                    (.deleteComment(postId: "", commentId: ""), .noContentType),
                    (.deleteLove(postId: ""), .noContentType),
                    (.deletePost(postId: ""), .noContentType),
                    (.deleteSubscriptions(token: Data()), .noContentType),
                    (.discover(type: .featured), .postsType),
                    (.discover(type: .trending), .postsType),
                    (.discover(type: .recent), .postsType),
                    (.categoryPosts(slug: "art"), .postsType),
                    (.emojiAutoComplete(terms: ""), .autoCompleteResultType),
                    (.findFriends(contacts: ["": [""]]), .usersType),
                    (.flagComment(postId: "", commentId: "", kind: ""), .noContentType),
                    (.flagPost(postId: "", kind: ""), .noContentType),
                    (.following, .postsType),
                    (.followingNewContent(createdAt: nil), .noContentType),
                    (.infiniteScroll(query: URLComponents(), api: .amazonCredentials), .amazonCredentialsType),
                    (.invitations(emails: [""]), .noContentType),
                    (.inviteFriends(email: ""), .noContentType),
                    (.join(email: "", username: "", password: "", invitationCode: ""), .usersType),
                    (.loves(userId: ""), .lovesType),
                    (.loves(userId: currentUserId), .lovesType),
                    (.notificationsNewContent(createdAt: nil), .noContentType),
                    (.notificationsStream(category: ""), .activitiesType),
                    (.postComments(postId: ""), .commentsType),
                    (.postDetail(postParam: ""), .postsType),
                    (.postLovers(postId: ""), .usersType),
                    (.postReposters(postId: ""), .usersType),
                    (.profileDelete, .noContentType),
                    (.profileToggles, .dynamicSettingsType),
                    (.profileUpdate(body: ["": ""]), .usersType),
                    (.pushSubscriptions(token: Data()), .noContentType),
                    (.reAuth(token: ""), .noContentType),
                    (.rePost(postId: ""), .postsType),
                    (.relationship(userId: "", relationship: ""), .relationshipsType),
                    (.relationshipBatch(userIds: [""], relationship: ""), .noContentType),
                    (.searchForUsers(terms: ""), .usersType),
                    (.searchForPosts(terms: ""), .postsType),
                    (.updatePost(postId: "", body: ["": ""]), .postsType),
                    (.updateComment(postId: "", commentId: "", body: ["": ""]), .commentsType),
                    (.userCategories(categoryIds: [""]), .noContentType),
                    (.userStream(userParam: ""), .usersType),
                    (.userStream(userParam: currentUserId), .usersType),
                    (.userStreamFollowers(userId: ""), .usersType),
                    (.userStreamFollowing(userId: ""), .usersType),
                    (.userNameAutoComplete(terms: ""), .autoCompleteResultType)
                ]
                for (endpoint, mappingType) in expectations {
                    it("\(endpoint) has the correct mappingType \(mappingType)") {
                        expect(endpoint.mappingType) == mappingType
                    }
                }
            }

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

                context("Accept-Language endpoints") {
                    let endpoints: [ElloAPI] = [
                        .amazonCredentials,
                        .anonymousCredentials,
                        .auth(email: "", password: ""),
                        .availability(content: [:]),
                        .createComment(parentPostId: "", body: [:]),
                        .createLove(postId: ""),
                        .createPost(body: [:]),
                        .deleteComment(postId: "", commentId: ""),
                        .deleteLove(postId: ""),
                        .deletePost(postId: ""),
                        .deleteSubscriptions(token: Data()),
                        .discover(type: .trending),
                        .categoryPosts(slug: ""),
                        .emojiAutoComplete(terms: ""),
                        .findFriends(contacts: [:]),
                        .flagComment(postId: "", commentId: "", kind: ""),
                        .flagPost(postId: "", kind: ""),
                        .followingNewContent(createdAt: nil),
                        .following,
                        .infiniteScroll(query: URLComponents(), api: .auth(email: "", password: "")),
                        .infiniteScroll(query: URLComponents(), api: .following),
                        .invitations(emails: [""]),
                        .inviteFriends(email: ""),
                        .join(email: "", username: "", password: "", invitationCode: ""),
                        .loves(userId: ""),
                        .notificationsNewContent(createdAt: nil),
                        .notificationsStream(category: ""),
                        .postComments(postId: ""),
                        .postDetail(postParam: ""),
                        .postLovers(postId: ""),
                        .postReposters(postId: ""),
                        .profileDelete,
                        .profileToggles,
                        .profileUpdate(body: [:]),
                        .pushSubscriptions(token: Data()),
                        .reAuth(token: ""),
                        .relationship(userId: "", relationship: ""),
                        .relationshipBatch(userIds: [""], relationship: ""),
                        .rePost(postId: ""),
                        .searchForPosts(terms: ""),
                        .searchForUsers(terms: ""),
                        .userNameAutoComplete(terms: ""),
                        .userCategories(categoryIds: [""]),
                        .userStream(userParam: ""),
                        .userStreamFollowers(userId: ""),
                        .userStreamFollowing(userId: ""),
                        ]
                    for endpoint in endpoints {
                        it("\(endpoint) has the correct headers") {
                            expect(endpoint.headers()["Accept-Language"]) == ""
                            expect(endpoint.headers()["Accept"]) == "application/json"
                            expect(endpoint.headers()["Content-Type"]) == "application/json"
                        }
                    }
                }

                context("If-Modified-Since endpoints") {
                    let date = Globals.now
                    let endpoints: [ElloAPI] = [
                        .followingNewContent(createdAt: date),
                        .notificationsNewContent(createdAt: date)
                    ]
                    for endpoint in endpoints {
                        it("\(endpoint) has the correct headers") {
                            expect(endpoint.headers()["If-Modified-Since"]) == date.toHTTPDateString()
                        }
                    }
                }

                context("build number header") {
                    let endpoint: ElloAPI = .amazonCredentials
                    it("should include build number") {
                        let expected = Bundle.main.infoDictionary![kCFBundleVersionKey as String] as! String
                        expect(endpoint.headers()["X-iOS-Build-Number"]) == expected
                        expect(endpoint.headers()["X-iOS-Build-Number"]).to(match("^\\d+$"))
                    }
                }

                context("normal authorization required") {
                    let endpoints: [ElloAPI] = [
                        .amazonCredentials,
                        .availability(content: [:]),
                        .createComment(parentPostId: "", body: [:]),
                        .createLove(postId: ""),
                        .createPost(body: [:]),
                        .deleteComment(postId: "", commentId: ""),
                        .deleteLove(postId: ""),
                        .deletePost(postId: ""),
                        .deleteSubscriptions(token: Data()),
                        .discover(type: .trending),
                        .categoryPosts(slug: ""),
                        .emojiAutoComplete(terms: ""),
                        .findFriends(contacts: ["": [""]]),
                        .flagComment(postId: "", commentId: "", kind: ""),
                        .flagPost(postId: "", kind: ""),
                        .following,
                        .infiniteScroll(query: URLComponents(), api: .following),
                        .invitations(emails: [""]),
                        .inviteFriends(email: ""),
                        .join(email: "", username: "", password: "", invitationCode: ""),
                        .loves(userId: ""),
                        .notificationsStream(category: ""),
                        .postComments(postId: ""),
                        .postDetail(postParam: ""),
                        .postLovers(postId: ""),
                        .postReposters(postId: ""),
                        .profileDelete,
                        .profileToggles,
                        .profileUpdate(body: [:]),
                        .rePost(postId: ""),
                        .pushSubscriptions(token: Data()),
                        .relationship(userId: "", relationship: ""),
                        .relationshipBatch(userIds: [""], relationship: ""),
                        .searchForUsers(terms: ""),
                        .searchForPosts(terms: ""),
                        .userCategories(categoryIds: [""]),
                        .userStream(userParam: ""),
                        .userStreamFollowers(userId: ""),
                        .userStreamFollowing(userId: ""),
                        .userNameAutoComplete(terms: "")
                    ]
                    for endpoint in endpoints {
                        it("\(endpoint) has the correct headers") {
                            expect(endpoint.headers()["Authorization"]) == AuthToken().tokenWithBearer ?? ""
                        }
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

                it("discover") {
                    let params = ElloAPI.discover(type: .featured).parameters!
                    expect(params["per_page"] as? Int) == 10
                }

                it("categoryPosts") {
                    let params = ElloAPI.categoryPosts(slug: "art").parameters!
                    expect(params["per_page"] as? Int) == 10
                }

                xit("findFriends") {

                }

                it("following") {
                    let params = ElloAPI.following.parameters!
                    expect(params["per_page"] as? Int) == 10
                }

                it("infiniteScroll") {
                    let query = URLComponents(string: "ttp://ello.co/api/v2/posts/278/comments?after=2014-06-02T00%3A00%3A00.000000000%2B0000&per_page=2")!
                    let infiniteScroll = ElloAPI.infiniteScroll(query: query, api: .discover(type: .featured))
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
                    let params = ElloAPI.userCategories(categoryIds: ["456"]).parameters!
                    expect(params["followed_category_ids"] as? [String]) == ["456"]
                }
            }

            describe("valid enpoints") {
                describe("with stubbed responses") {
                    describe("a provider") {
                        it("returns stubbed data for auth request") {
                            var message: String?

                            let target: ElloAPI = .auth(email:"test@example.com", password: "123456")
                            provider.request(target, completion: { (result) in
                                switch result {
                                case let .success(moyaResponse):
                                    message = String(data: moyaResponse.data, encoding: String.Encoding.utf8)
                                default: break
                                }
                            })

                            let sampleData = target.sampleData as Data
                            expect(message) == String(data: sampleData, encoding: String.Encoding.utf8)
                        }

                        it("returns stubbed data for following request") {
                            var message: String?

                            let target: ElloAPI = .following
                            provider.request(target, completion: { (result) in
                                switch result {
                                case let .success(moyaResponse):
                                    message = String(data: moyaResponse.data, encoding: String.Encoding.utf8)
                                default: break
                                }
                            })

                            let sampleData = target.sampleData as Data
                            expect(message) == String(data: sampleData, encoding: String.Encoding.utf8)
                        }
                    }
                }
            }
        }
    }
}
