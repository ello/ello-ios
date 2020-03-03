////
///  StreamCellTypeSpec.swift
//

@testable import Ello
import Quick
import Nimble


class StreamCellTypeSpec: QuickSpec {
    override func spec() {
        describe("StreamCellType") {
            describe("handles equality") {
                describe("sanity checks") {
                    for (index, type) in StreamCellType.all.enumerated() {
                        it("checking equality \(type)") {
                            for (cmpIndex, cmpType) in StreamCellType.all.enumerated() {
                                if index == cmpIndex {
                                    expect(type).to(
                                        equal(cmpType),
                                        description: "should equal \(cmpType)"
                                    )
                                }
                                else {
                                    expect(type).notTo(
                                        equal(cmpType),
                                        description: "should not equal \(cmpType)"
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
