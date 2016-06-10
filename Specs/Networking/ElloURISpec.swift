//
//  ElloURISpec.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/2/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Ello
import Quick
import Nimble
import Moya


class ElloURISpec: QuickSpec {
    override func spec() {
        describe("ElloURI") {

            describe("baseURL") {

                it("can be constructed with ello-staging and http") {
                    ElloURI.domain = "ello-staging.herokuapp.com"
                    ElloURI.httpProtocol = "http"
                    expect(ElloURI.baseURL).to(equal("http://ello-staging.herokuapp.com"))
                }

                it("can be constructed with ello.co and https") {
                    ElloURI.domain = "ello.co"
                    ElloURI.httpProtocol = "https"
                    expect(ElloURI.baseURL).to(equal("https://ello.co"))
                }

            }

            describe("ElloURI.match") {

                describe("with Search urls") {

                    it("does not match https://www.ello.co/searchyface") {
                        let (type, _) = ElloURI.match("https://www.ello.co/searchyface")
                        expect(type).notTo(equal(ElloURI.Search))
                    }
                }


                describe("with Email addresses") {

                    it("matches with mailto:archer@example.com") {
                        let (type, data) = ElloURI.match("mailto:archer@example.com")
                        expect(type).to(equal(ElloURI.Email))
                        expect(data).to(equal("mailto:archer@example.com"))
                    }

                }

                let domains = [
                    "http://ello.co",
                    "http://ello-staging.herokuapp.com",
                    "http://ello-staging2.herokuapp.com",
                    "http://staging.ello.co",
                    "https://ello.co",
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
                    ElloURI.domain = "ello-staging.herokuapp.com"
                    ElloURI.httpProtocol = "https"
                }

                describe("root urls") {

                    describe("with root domain urls") {
                        it("matches route correctly") {
                            for domain in domains {
                                let (type, data) = ElloURI.match(domain)

                                expect(type).to(equal(ElloURI.Root))
                                expect(data) == domain
                            }
                        }
                    }
                }

                describe("specific urls") {
                    let tests: [String: (input: String, outputURI: ElloURI, outputData: String)] = [

                        "with ello://notification url schemes": (
                            input: "ello://notifications",
                            outputURI: .Notifications,
                            outputData: "notifications"
                        ),
                        "with ello://777/followers url schemes": (
                            input: "ello://777/followers",
                            outputURI: .ProfileFollowers,
                            outputData: "777"
                        ),
                        "with Subdomain(short) urls": (
                            input: "https://flowers.ello.co",
                            outputURI: .Subdomain,
                            outputData: "https://flowers.ello.co"
                        ),
                        "with Subdomain(long) urls": (
                            input: "https://wallpapers.ello.co/any/thing/else/here",
                            outputURI: .Subdomain,
                            outputData: "https://wallpapers.ello.co/any/thing/else/here"
                        ),
                        "with root wtf urls": (
                            input: "https://ello.co/wtf",
                            outputURI: .WTF,
                            outputData: "https://ello.co/wtf"
                        ),
                        "with wtf/help urls": (
                            input: "https://ello.co/wtf/help",
                            outputURI: .WTF,
                            outputData: "https://ello.co/wtf/help"
                        ),
                    ]

                    for (description, test) in tests {

                        describe(description) {
                            it("matches route correctly") {
                                let (type, data) = ElloURI.match(test.input)

                                expect(type).to(equal(test.outputURI))
                                expect(data) == test.outputData
                            }
                        }
                    }
                }

                describe("app loadable routes with query params") {
                    let tests: [String: (input: String, outputURI: ElloURI, outputData: String)] = [
                        "with Search(query param) urls": (input: "search?terms=%23hashtag", outputURI: .Search, outputData: "#hashtag"),
                        "with Find(query param) urls": (input: "find?terms=%23hashtag", outputURI: .Search, outputData: "#hashtag"),
                        "with Profile(query param) urls": (input: "666?expanded=true", outputURI: .Profile, outputData: "666"),
                        "with Post(query param) urls": (input: "777/post/123?expanded=true", outputURI: .Post, outputData: "123"),
                    ]

                    for (description, test) in tests {

                        describe(description) {
                            it("matches route correctly") {

                                for domain in domains {
                                    let (typeNoSlash, dataNoSlash) = ElloURI.match("\(domain)/\(test.input)")

                                    expect(typeNoSlash).to(equal(test.outputURI))
                                    expect(dataNoSlash) == test.outputData
                                }
                            }
                        }
                    }
                }

                describe("push notifiation routes") {
                    let tests: [String: (input: String, outputURI: ElloURI, outputData: String)] = [
                        "with User urls": (input: "notifications/users/696", outputURI: .PushNotificationUser, outputData: "696"),
                        "with Post urls": (input: "notifications/posts/2345", outputURI: .PushNotificationPost, outputData: "2345"),
                        "with Post Comment urls": (input: "notifications/posts/2345/comments/666", outputURI: .PushNotificationComment, outputData: "2345"),
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
                    let tests: [String: (input: String, outputURI: ElloURI, outputData: String)] = [
                        "with Search urls": (input: "search", outputURI: .Search, outputData: ""),
                        "with Find urls": (input: "find", outputURI: .Search, outputData: ""),
                        "with Profile urls": (input: "666", outputURI: .Profile, outputData: "666"),
                        "with ProfileFollowers urls": (input: "777/followers", outputURI: .ProfileFollowers, outputData: "777"),
                        "with ProfileFollowing urls": (input: "888/following", outputURI: .ProfileFollowing, outputData: "888"),
                        "with ProfileLoves urls": (input: "999/loves", outputURI: .ProfileLoves, outputData: "999"),
                        "with Post urls": (input: "666/post/2345", outputURI: .Post, outputData: "2345"),
                        "with Notifications urls": (input: "notifications", outputURI: .Notifications, outputData: "notifications"),
                        "with Notifications/all urls": (input: "notifications/all", outputURI: .Notifications, outputData: "all"),
                        "with Notifications/comments urls": (input: "notifications/comments", outputURI: .Notifications, outputData: "comments"),
                        "with Notifications/loves urls": (input: "notifications/loves", outputURI: .Notifications, outputData: "loves"),
                        "with Notifications/mentions urls": (input: "notifications/mentions", outputURI: .Notifications, outputData: "mentions"),
                        "with Notifications/reposts urls": (input: "notifications/reposts", outputURI: .Notifications, outputData: "reposts"),
                        "with Notifications/relationshiops urls": (input: "notifications/relationships", outputURI: .Notifications, outputData: "relationships"),
                    ]

                    for (description, test) in tests {

                        describe(description) {
                            it("matches route correctly") {

                                for domain in domains {
                                    let (typeNoSlash, dataNoSlash) = ElloURI.match("\(domain)/\(test.input)")

                                    expect(typeNoSlash).to(equal(test.outputURI))
                                    expect(dataNoSlash) == test.outputData

                                    let (typeYesSlash, dataYesSlash) = ElloURI.match("\(domain)/\(test.input)/")

                                    expect(typeYesSlash).to(equal(test.outputURI))
                                    expect(dataYesSlash) == test.outputData
                                }
                            }
                        }
                    }
                }

                describe("with External urls") {

                    it("matches with http://google.com") {
                        let (type, data) = ElloURI.match("http://www.google.com")
                        expect(type).to(equal(ElloURI.External))
                        expect(data).to(equal("http://www.google.com"))
                    }

                    it("matches with https://www.vimeo.com/anything/") {
                        let (type, data) = ElloURI.match("https://www.vimeo.com/anything/")
                        expect(type).to(equal(ElloURI.External))
                        expect(data).to(equal("https://www.vimeo.com/anything/"))
                    }
                }

                describe("with WTF urls") {
                    it("matches with http://google.com") {
                        let (type, data) = ElloURI.match("http://www.google.com")
                        expect(type).to(equal(ElloURI.External))
                        expect(data).to(equal("http://www.google.com"))
                    }

                    it("matches with https://www.vimeo.com/anything/") {
                        let (type, data) = ElloURI.match("https://www.vimeo.com/anything/")
                        expect(type).to(equal(ElloURI.External))
                        expect(data).to(equal("https://www.vimeo.com/anything/"))
                    }
                }

                describe("with native_redirect urls") {
                    it("matches with https://ello.co/native_redirect?target=https%3A%2F%2Fello.co%2Felloblog") {
                        let (type, data) = ElloURI.match("https://ello.co/native_redirect?target=https%3A%2F%2Fello.co%2Felloblog")
                        expect(type).to(equal(ElloURI.Profile))
                        expect(data).to(equal("elloblog"))
                    }

                    it("matches with https://ello.co/native_redirect?target=https%3A%2F%2Fello.co%2Felloblog%2Fpost%2F123") {
                        let (type, data) = ElloURI.match("https://ello.co/native_redirect?target=https%3A%2F%2Fello.co%2Felloblog%2Fpost%2F123")
                        expect(type).to(equal(ElloURI.Post))
                        expect(data).to(equal("123"))
                    }
                }

                describe("known ello root routes") {
                    let tests: [String: (input: String, output: ElloURI)] = [
                        "with Confirm urls": (input: "confirm", output: .Confirm),
                        "with BetaPublicProfiles urls": (input: "beta-public-profiles", output: .BetaPublicProfiles),
                        "with Discover urls": (input: "discover", output: .Discover),
                        "with DiscoverRandom urls": (input: "discover/random", output: .DiscoverRandom),
                        "with DiscoverRelated urls": (input: "discover/related", output: .DiscoverRelated),
                        "with DiscoverRecent urls": (input: "discover/recent", output: .DiscoverRecent),
                        "with DiscoverTrending urls": (input: "discover/trending", output: .DiscoverTrending),
                        "with Downloads urls": (input: "downloads", output: .Downloads),
                        "with Enter urls": (input: "enter", output: .Enter),
                        "with Explore urls": (input: "explore", output: .Explore),
                        "with Explore Trending urls": (input: "explore/trending", output: .ExploreTrending),
                        "with Explore Recent urls": (input: "explore/recent", output: .ExploreRecent),
                        "with Explore Recommended urls": (input: "explore/recommended", output: .ExploreRecommended),
                        "with Exit urls": (input: "exit", output: .Exit),
                        "with FaceMaker urls": (input: "facemaker", output: .FaceMaker),
                        "with ForgotMyPassword urls": (input: "forgot-my-password", output: .ForgotMyPassword),
                        "with Friends urls": (input: "friends", output: .Friends),
                        "with FreedomOfSpeech urls": (input: "freedom-of-speech", output: .FreedomOfSpeech),
                        "with Invitations urls": (input: "invitations", output: .Invitations),
                        "with Join urls": (input: "join", output: .Join),
                        "with Login urls": (input: "login", output: .Login),
                        "with Manifesto urls": (input: "manifesto", output: .Manifesto),
                        "with NativeRedirect urls": (input: "native_redirect", output: .NativeRedirect),
                        "with Noise urls": (input: "noise", output: .Noise),
                        "with Onboarding urls": (input: "onboarding", output: .Onboarding),
                        "with PasswordResetError urls": (input: "password-reset-error", output: .PasswordResetError),
                        "with RandomSearch urls": (input: "random_searches", output: .RandomSearch),
                        "with RequestInvite urls": (input: "request-an-invite", output: .RequestInvite),
                        "with RequestInvitation urls": (input: "request-an-invitation", output: .RequestInvitation),
                        "with RequestInvitations urls": (input: "request_invitations", output: .RequestInvitations),
                        "with ResetMyPassword urls": (input: "reset-my-password", output: .ResetMyPassword),
                        "with SearchPeople urls": (input: "search/people", output: .SearchPeople),
                        "with FindPeople urls": (input: "find/people", output: .SearchPeople),
                        "with SearchPosts urls": (input: "search/posts", output: .SearchPosts),
                        "with FindPosts urls": (input: "find/posts", output: .SearchPosts),
                        "with Settings urls": (input: "settings", output: .Settings),
                        "with Unblock urls": (input: "unblock", output: .Unblock),
                        "with WhoMadeThis urls": (input: "who-made-this", output: .WhoMadeThis),
                    ]

                    for (description, test) in tests {

                        describe(description) {
                            it("matches route correctly") {

                                for domain in domains {
                                    let (typeNoSlash, dataNoSlash) = ElloURI.match("\(domain)/\(test.input)")

                                    expect(typeNoSlash).to(equal(test.output))
                                    expect(dataNoSlash) == "\(domain)/\(test.input)"

                                    let (typeYesSlash, dataYesSlash) = ElloURI.match("\(domain)/\(test.input)/")

                                    expect(typeYesSlash).to(equal(test.output))
                                    expect(dataYesSlash) == "\(domain)/\(test.input)/"

                                    let (typeTrailingChars, _) = ElloURI.match("\(domain)/\(test.input)foo")
                                    expect(typeTrailingChars).notTo(equal(test.output))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
