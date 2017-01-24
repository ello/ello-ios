////
///  ElloLinkedStoreSpec.swift
//

@testable import Ello
import Quick
import Nimble

class ElloLinkedStoreSpec: QuickSpec {
    override func spec() {

        xdescribe("-parseLinked:") {

            it("parses 'linked' and adds objects to Store") {
                let linked = [
                    "superheroes":[
                        ["id":"batman" as AnyObject],
                        ["id":"superman" as AnyObject]
                    ],
                    "villians":[
                        ["id":"joker" as AnyObject],
                        ["id":"lex luther" as AnyObject]
                    ]
                ]
                ElloLinkedStore.sharedInstance.parseLinked(linked, completion: {})

//                expect(ElloLinkedStore.sharedInstance.store["superheroes"]?["batman"]).toNot(beNil())
//                expect(ElloLinkedStore.sharedInstance.store["villians"]?["lex luther"]).toNot(beNil())
            }

//            it("parses 'linked' and adds objects to Store") {
//                stubbedJSONDataArray("activity_streams_friend_stream", "activities")
//                expect(ElloLinkedStore.store["posts"]?["2"] as? Post).to(beAKindOf(Post.self))
//                expect(ElloLinkedStore.store["posts"]?["1"] as? Post).to(beAKindOf(Post.self))
//                expect(ElloLinkedStore.store["users"]?["42"] as? User).to(beAKindOf(User.self))
//                expect(ElloLinkedStore.store["users"]?["666"] as? User).to(beAKindOf(User.self))
//            }
        }
    }
}
