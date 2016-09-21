////
///  NewContentServiceSpec.swift
//

import Ello
import Quick
import Nimble
import Moya
import SwiftyUserDefaults

class NewContentServiceSpec: QuickSpec {
    override func spec() {
        describe("NewContentService") {

            var subject = NewContentService()

            beforeEach {
                subject = NewContentService()
            }

            describe("updateCreatedAt(_:)") {

                let sep_30_1978 = NSDate(timeIntervalSince1970: 275961600)
                let jan_01_2015 = NSDate(timeIntervalSince1970: 1420070400)
                let feb_01_2015 = NSDate(timeIntervalSince1970: 1422748800)
                let mar_01_2015 = NSDate(timeIntervalSince1970: 1425168000)
                let apr_01_2015 = NSDate(timeIntervalSince1970: 1427846400)
                let streamKind = StreamKind.Following

                let post: Post = stub(["id" : "1", "createdAt" : jan_01_2015])
                let post2: Post = stub(["id" : "2", "createdAt" : feb_01_2015])
                let post3: Post = stub(["id" : "3", "createdAt" : mar_01_2015])

                let jsonables = [post, post2, post3]

                beforeEach {
                    GroupDefaults[streamKind.lastViewedCreatedAtKey] = nil
                }


                context("no existing date stored") {

                    it("stores the created_at of the most recent jsonable") {
                        GroupDefaults[streamKind.lastViewedCreatedAtKey] = nil
                        subject.updateCreatedAt(jsonables, streamKind: streamKind)

                        expect(GroupDefaults[streamKind.lastViewedCreatedAtKey].date) == mar_01_2015
                    }
                }

                context("older existing date stored") {

                    it("stores the created_at of the most recent jsonable") {
                        GroupDefaults[streamKind.lastViewedCreatedAtKey] = sep_30_1978
                        subject.updateCreatedAt(jsonables, streamKind: streamKind)

                        expect(GroupDefaults[streamKind.lastViewedCreatedAtKey].date) == mar_01_2015
                    }
                }

                context("newer existing date stored") {

                    it("keeps the existing date") {
                        GroupDefaults[streamKind.lastViewedCreatedAtKey] = apr_01_2015
                        subject.updateCreatedAt(jsonables, streamKind: streamKind)

                        expect(GroupDefaults[streamKind.lastViewedCreatedAtKey].date) == apr_01_2015
                    }
                }

                context("jsonables with no created at") {

                    it("sets an old date ignoring the jsonables") {
                        let user: User = stub(["id" : "1"])
                        let user2: User = stub(["id" : "2"])
                        let user3: User = stub(["id" : "3"])
                        let jsonables = [user, user2, user3]
                        let old = NSDate(timeIntervalSince1970: 0)

                        GroupDefaults[streamKind.lastViewedCreatedAtKey] = nil

                        subject.updateCreatedAt(jsonables, streamKind: streamKind)

                        expect(GroupDefaults[streamKind.lastViewedCreatedAtKey].date) == old
                    }
                }
            }

            describe("startPolling()") {
                // difficult to unit test, need the ability to force it to run synchronously
            }

            describe("stopPolling()") {
                // difficult to unit test, need the ability to force it to run synchronously
            }

            describe("checkForNewContent()") {
                // difficult to unit test, need the ability to stub response config, currently
                // there is no mechanism for sutbbing a status code
            }
        }
    }
}
