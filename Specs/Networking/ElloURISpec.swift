////
///  ElloURISpec.swift
//

@testable import Ello
import Quick
import Nimble
import Moya


class ElloURISpec: QuickSpec {
    override func spec() {
        describe("ElloURI") {

            describe("baseURL") {
                afterEach {
                    APIKeys.shared = APIKeys.default
                }

                it("can be constructed with ello-staging and http") {
                    let testingKeys = APIKeys(
                        key: "", secret: "", segmentKey: "",
                        domain: "http://ello-staging.herokuapp.com",
                        hasGraphQL: false
                        )
                    APIKeys.shared = testingKeys
                    expect(ElloURI.baseURL).to(equal("http://ello-staging.herokuapp.com"))
                }

                it("can be constructed with ello.co and https") {
                    let testingKeys = APIKeys(
                        key: "", secret: "", segmentKey: "",
                        domain: "https://ello.co",
                        hasGraphQL: false
                        )
                    APIKeys.shared = testingKeys
                    expect(ElloURI.baseURL).to(equal("https://ello.co"))
                }

            }

            describe("ElloURI.match") {

                describe("with Search urls") {
                    it("does not match https://www.ello.co/searchyface") {
                        let (type, _) = ElloURI.match("https://www.ello.co/searchyface")
                        expect(type).notTo(equal(ElloURI.search))
                    }
                }


                describe("with Email addresses") {

                    it("matches with mailto:archer@example.com") {
                        let email = "mailto:archer@example.com"
                        let (type, data) = ElloURI.match(email)
                        expect(type) == ElloURI.email
                        expect(data) == email
                    }

                }

                let domains = [
                    "http://ello.co",
                    "http://ello-staging.herokuapp.com",
                    "http://ello-staging2.herokuapp.com",
                    "http://staging.ello.co",
                    "https://ello.co",
                    "https://ello.ninja",
                    "https://ello-staging.herokuapp.com",
                    "https://ello-staging1.herokuapp.com",
                    "https://ello-stage.herokuapp.com",
                    "https://ello-stage2.herokuapp.com",
                    "https://staging.ello.co",
                    "https://ello-staging2.herokuapp.com",
                    "https://ello-fg-stage1.herokuapp.com",
                    "https://ello-fg-stage2.herokuapp.com",
                ]

                beforeEach {
                    let testingKeys = APIKeys(
                        key: "", secret: "", segmentKey: "",
                        domain: "https://ello-staging.herokuapp.com",
                        hasGraphQL: false
                        )
                    APIKeys.shared = testingKeys
                }
                afterEach {
                    APIKeys.shared = APIKeys.default
                }

                describe("root urls") {

                    describe("with root domain urls") {
                        it("matches route correctly") {
                            for domain in domains {
                                let (type, data) = ElloURI.match(domain)

                                expect(type).to(equal(ElloURI.root))
                                expect(data) == domain
                            }
                        }
                    }
                }

                describe("specific urls") {
                    let tests: [String: (input: String, outputURI: ElloURI, outputData: String?)] = [
                        "with ello://notification url schemes": (
                            input: "ello://notifications",
                            outputURI: .notifications,
                            outputData: nil
                        ),
                        "with ello://777/followers url schemes": (
                            input: "ello://777/followers",
                            outputURI: .profileFollowers,
                            outputData: "777"
                        ),
                        "with Subdomain(short) urls": (
                            input: "https://flowers.ello.co",
                            outputURI: .subdomain,
                            outputData: "https://flowers.ello.co"
                        ),
                        "with Category urls": (
                            input: "https://ello.co/discover/art",
                            outputURI: .category,
                            outputData: "art"
                        ),
                        "with Subdomain(long) urls": (
                            input: "https://wallpapers.ello.co/any/thing/else/here",
                            outputURI: .subdomain,
                            outputData: "https://wallpapers.ello.co/any/thing/else/here"
                        ),
                        "with root wtf urls": (
                            input: "https://ello.co/wtf",
                            outputURI: .wtf,
                            outputData: nil
                        ),
                        "with wtf/help urls": (
                            input: "https://ello.co/wtf/help",
                            outputURI: .wtf,
                            outputData: nil
                        ),
                        "with reset password urls": (
                            input: "https://ello.co/auth/reset-my-password?reset_password_token=abc12--abcdefg12345",
                            outputURI: .resetMyPassword,
                            outputData: "abc12--abcdefg12345"
                        ),
                    ]

                    for (description, test) in tests {

                        describe(description) {
                            it("matches route correctly") {
                                let (type, data) = ElloURI.match(test.input)

                                expect(type).to(equal(test.outputURI))
                                if let outputData = test.outputData {
                                    expect(data) == outputData
                                }
                                else {
                                    expect(data).to(beNil())
                                }
                            }
                        }
                    }
                }

                describe("app loadable routes with query params") {
                    let tests: [String: (input: String, outputURI: ElloURI, outputData: String)] = [
                        "with Search(query param) urls": (input: "search?terms=%23hashtag", outputURI: .search, outputData: "#hashtag"),
                        "with SearchPosts(query param) urls": (input: "search/posts/?terms=%23hashtag", outputURI: .searchPosts, outputData: "#hashtag"),
                        "with SearchUsers(query param) urls": (input: "search/people/?terms=%40hashtag", outputURI: .searchPeople, outputData: "@hashtag"),
                        "with Find(query param) urls": (input: "find?terms=%23hashtag", outputURI: .search, outputData: "#hashtag"),
                        "with Profile(query param) urls": (input: "666?expanded=true", outputURI: .profile, outputData: "666"),
                        "with Post(query param) urls": (input: "777/post/123?expanded=true", outputURI: .post, outputData: "123"),
                    ]

                    for (description, test) in tests {
                        for domain in domains {

                            describe("\(description) in domain \(domain)") {
                                it("matches route correctly") {
                                    let (type, data) = ElloURI.match("\(domain)/\(test.input)")

                                    expect(type).to(equal(test.outputURI))
                                    expect(data) == test.outputData
                                }
                            }
                        }
                    }
                }

                describe("push notification routes") {
                    let tests: [String: (input: String, outputURI: ElloURI, outputData: String)] = [
                        "with URL urls": (input: "notifications/ello.co/wtf/support/featured-members/", outputURI: .pushNotificationURL, outputData: "wtf/support/featured-members/"),
                        "with User urls": (input: "notifications/users/696", outputURI: .pushNotificationUser, outputData: "696"),
                        "with Post urls": (input: "notifications/posts/2345", outputURI: .pushNotificationPost, outputData: "2345"),
                        "with Post Comment urls": (input: "notifications/posts/2345/comments/666", outputURI: .pushNotificationComment, outputData: "2345"),
                    ]

                    for (description, test) in tests {

                        describe(description) {
                            it("matches route correctly") {
                                let (type, data) = ElloURI.match("\(test.input)")
                                expect(type).to(equal(test.outputURI))
                                expect(data) == test.outputData
                            }
                        }
                    }
                }

                describe("app loadable routes") {
                    let tests: [String: (input: String, outputURI: ElloURI, outputData: String?)] = [
                        "with Search urls": (input: "search", outputURI: .search, outputData: nil),
                        "with Find urls": (input: "find", outputURI: .search, outputData: nil),
                        "with Profile urls": (input: "666", outputURI: .profile, outputData: "666"),
                        "with ProfileFollowers urls": (input: "777/followers", outputURI: .profileFollowers, outputData: "777"),
                        "with ProfileFollowing urls": (input: "888/following", outputURI: .profileFollowing, outputData: "888"),
                        "with ProfileLoves urls": (input: "999/loves", outputURI: .profileLoves, outputData: "999"),
                        "with Discover urls": (input: "discover", outputURI: .discover, outputData: "recommended"),
                        "with DiscoverRandom urls": (input: "discover/random", outputURI: .discoverRandom, outputData: "random"),
                        "with DiscoverRecent urls": (input: "discover/recent", outputURI: .discoverRecent, outputData: "recent"),
                        "with DiscoverRelated urls": (input: "discover/related", outputURI: .discoverRelated, outputData: "related"),
                        "with DiscoverTrending urls": (input: "discover/trending", outputURI: .discoverTrending, outputData: "trending"),
                        "with Post urls": (input: "666/post/2345", outputURI: .post, outputData: "2345"),
                        "with Category urls": (input: "discover/art", outputURI: .category, outputData: "art"),
                        "with Notifications urls": (input: "notifications", outputURI: .notifications, outputData: nil),
                        "with Notifications/all urls": (input: "notifications/all", outputURI: .notifications, outputData: "all"),
                        "with Notifications/comments urls": (input: "notifications/comments", outputURI: .notifications, outputData: "comments"),
                        "with Notifications/loves urls": (input: "notifications/loves", outputURI: .notifications, outputData: "loves"),
                        "with Notifications/mentions urls": (input: "notifications/mentions", outputURI: .notifications, outputData: "mentions"),
                        "with Notifications/reposts urls": (input: "notifications/reposts", outputURI: .notifications, outputData: "reposts"),
                        "with Notifications/relationshiops urls": (input: "notifications/relationships", outputURI: .notifications, outputData: "relationships"),
                    ]

                    for (description, test) in tests {

                        describe(description) {
                            for domain in domains {
                                it("matches route correctly with slash") {
                                    let (type, data) = ElloURI.match("\(domain)/\(test.input)")

                                    expect(type).to(equal(test.outputURI))
                                    if let outputData = test.outputData {
                                        expect(data) == outputData
                                    }
                                    else {
                                        expect(data).to(beNil())
                                    }
                                }

                                it("matches route correctly without slash") {
                                    let (type, data) = ElloURI.match("\(domain)/\(test.input)/")

                                    expect(type).to(equal(test.outputURI))
                                    if let outputData = test.outputData {
                                        expect(data) == outputData
                                    }
                                    else {
                                        expect(data).to(beNil())
                                    }
                                }
                            }
                        }
                    }
                }

                describe("with External urls") {

                    it("matches with http://google.com") {
                        let (type, data) = ElloURI.match("http://www.google.com")
                        expect(type).to(equal(ElloURI.external))
                        expect(data).to(equal("http://www.google.com"))
                    }

                    it("matches with https://www.vimeo.com/anything/") {
                        let (type, data) = ElloURI.match("https://www.vimeo.com/anything/")
                        expect(type).to(equal(ElloURI.external))
                        expect(data).to(equal("https://www.vimeo.com/anything/"))
                    }
                }

                describe("known ello root routes") {
                    let tests: [String: (input: String, output: ElloURI)] = [
                        "with Confirm urls": (input: "confirm", output: .confirm),
                        "with BetaPublicProfiles urls": (input: "beta-public-profiles", output: .betaPublicProfiles),
                        "with Enter urls": (input: "enter", output: .enter),
                        "with Explore urls": (input: "explore", output: .explore),
                        "with Explore Trending urls": (input: "explore/trending", output: .exploreTrending),
                        "with Explore Recent urls": (input: "explore/recent", output: .exploreRecent),
                        "with Explore Recommended urls": (input: "explore/recommended", output: .exploreRecommended),
                        "with Exit urls": (input: "exit", output: .exit),
                        "with FaceMaker urls": (input: "facemaker", output: .faceMaker),
                        "with ForgotMyPassword urls": (input: "forgot-password", output: .forgotMyPassword),
                        "with Friends urls": (input: "friends", output: .friends),
                        "with FreedomOfSpeech urls": (input: "freedom-of-speech", output: .freedomOfSpeech),
                        "with Invitations urls": (input: "invitations", output: .invitations),
                        "with Join urls": (input: "join", output: .join),
                        "with Signup urls": (input: "signup", output: .signup),
                        "with Login urls": (input: "login", output: .login),
                        "with Manifesto urls": (input: "manifesto", output: .manifesto),
                        "with NativeRedirect urls": (input: "native_redirect", output: .nativeRedirect),
                        "with Noise urls": (input: "noise", output: .noise),
                        "with Onboarding urls": (input: "onboarding", output: .onboarding),
                        "with PasswordResetError urls": (input: "password-reset-error", output: .passwordResetError),
                        "with RandomSearch urls": (input: "random_searches", output: .randomSearch),
                        "with RequestInvite urls": (input: "request-an-invite", output: .requestInvite),
                        "with RequestInvitation urls": (input: "request-an-invitation", output: .requestInvitation),
                        "with RequestInvitations urls": (input: "request_invitations", output: .requestInvitations),
                        "with ResetPasswordError urls": (input: "auth/password-reset-error", output: .resetPasswordError),
                        "with Settings urls": (input: "settings", output: .settings),
                        "with Unblock urls": (input: "unblock", output: .unblock),
                        "with WhoMadeThis urls": (input: "who-made-this", output: .whoMadeThis),
                    ]

                    for (description, test) in tests {
                        for domain in domains {

                            describe("\(description) in domain \(domain)") {
                                it("matches route correctly, no slash") {
                                    let (type, _) = ElloURI.match("\(domain)/\(test.input)")
                                    expect(type).to(equal(test.output))
                                }

                                it("matches route correctly, trailing slash") {
                                    let (type, _) = ElloURI.match("\(domain)/\(test.input)/")
                                    expect(type).to(equal(test.output))
                                }

                                it("doesn't match route, trailing characters") {
                                    let (type, _) = ElloURI.match("\(domain)/\(test.input)&foo")
                                    expect(type).notTo(equal(test.output))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
