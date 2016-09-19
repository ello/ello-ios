////
///  UsernameSpec.swift
//

import Ello
import Quick
import Nimble


class UsernameSpec: QuickSpec {
    override func spec() {
        describe("Username") {
            describe("+fromJSON:") {

                it("parses correctly") {
                    let data = stubbedJSONDataArray("usernames", "usernames")
                    let username1Data = data[0]
                    let username2Data = data[1]
                    let username3Data = data[2]

                    let username1 = Username.fromJSON(username1Data) as! Username
                    let username2 = Username.fromJSON(username2Data) as! Username
                    let username3 = Username.fromJSON(username3Data) as! Username

                    expect(username1.username) == "user1"
                    expect(username2.username) == "user2"
                    expect(username3.username) == "user1"

                    expect(username1.atName) == "@user1"
                    expect(username2.atName) == "@user2"
                    expect(username3.atName) == "@user1"
                }
            }

            describe("atName") {
                it("returns the correct value") {
                    let username = Username(username: "bob")

                    expect(username.atName) == "@bob"
                }
            }

            context("NSCoding") {

                var filePath = ""
                if let url = NSURL(string: NSFileManager.ElloDocumentsDir()) {
                    filePath = url.URLByAppendingPathComponent("UsernameSpec")!.absoluteString!
                }

                afterEach {
                    do {
                        try NSFileManager.defaultManager().removeItemAtPath(filePath)
                    }
                    catch {

                    }
                }

                context("encoding") {

                    it("encodes successfully") {
                        let username: Username = stub([:])

                        let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(username, toFile: filePath)

                        expect(wasSuccessfulArchived).to(beTrue())
                    }
                }

                context("decoding") {

                    it("decodes successfully") {
                        let username: Username = stub(["username":"rob"])

                        NSKeyedArchiver.archiveRootObject(username, toFile: filePath)
                        let unArchivedUsername = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! Username

                        expect(unArchivedUsername).toNot(beNil())
                        expect(unArchivedUsername.version) == 1

                        expect(unArchivedUsername.username) == "rob"
                        expect(unArchivedUsername.atName) == "@rob"
                    }
                }
            }
        }
    }
}
