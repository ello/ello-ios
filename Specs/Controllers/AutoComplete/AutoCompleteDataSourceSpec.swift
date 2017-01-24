////
///  AutoCompleteDataSourceSpec.swift
//

@testable import Ello
import Quick
import Nimble


class AutoCompleteDataSourceSpec: QuickSpec {
    override func spec() {
        describe("AutoCompleteDataSource") {

            var subject = AutoCompleteDataSource()

            beforeEach {
                subject = AutoCompleteDataSource()
            }

            describe("itemForIndexPath(_:)") {

                beforeEach {
                    let match = AutoCompleteMatch(type: AutoCompleteType.username, range: (start: "test".startIndex..<"test".endIndex), text: "test")
                    let item1 = AutoCompleteItem(result: AutoCompleteResult(name: "test"), type: AutoCompleteType.username, match: match)
                    let item2 = AutoCompleteItem(result: AutoCompleteResult(name: "test"), type: AutoCompleteType.emoji, match: match)
                    let item3 = AutoCompleteItem(result: AutoCompleteResult(name: "test"), type: AutoCompleteType.username, match: match)
                    let item4 = AutoCompleteItem(result: AutoCompleteResult(name: "test"), type: AutoCompleteType.username, match: match)

                    let items = [item1, item2, item3, item4]
                    subject.items = items
                }

                context("index path exists") {

                    it("returns correct item") {
                        expect(subject.itemForIndexPath(IndexPath(row: 1, section: 0))?.type) == AutoCompleteType.emoji
                    }
                }

                context("index path does NOT exists") {

                    it("returns nil") {
                        expect(subject.itemForIndexPath(IndexPath(row: 100, section: 0))).to(beNil())
                    }
                }
            }

            context("UITableViewDataSource") {

                describe("tableView(_:numberOfrowsInSection:)") {

                    it("returns the correct count") {
                        let match = AutoCompleteMatch(type: AutoCompleteType.username, range: (start: "test".startIndex..<"test".endIndex), text: "test")
                        let item1 = AutoCompleteItem(result: AutoCompleteResult(name: "test"), type: AutoCompleteType.username, match: match)
                        let item2 = AutoCompleteItem(result: AutoCompleteResult(name: "test"), type: AutoCompleteType.username, match: match)
                        let item3 = AutoCompleteItem(result: AutoCompleteResult(name: "test"), type: AutoCompleteType.username, match: match)
                        let item4 = AutoCompleteItem(result: AutoCompleteResult(name: "test"), type: AutoCompleteType.username, match: match)

                        let items = [item1, item2, item3, item4]
                        subject.items = items

                        expect(subject.tableView(UITableView(frame: .zero), numberOfRowsInSection: 0)) == 4
                    }
                }

                describe("tableView(_:cellForRowAtIndexPath:)") {

                    var vc = AutoCompleteViewController()

                    beforeEach {
                        vc = AutoCompleteViewController()
                        showController(vc)
                    }

                    it("returns an AutoCompleteCell") {
                        let match = AutoCompleteMatch(type: AutoCompleteType.username, range: (start:"test".startIndex..<"test".endIndex), text: "test")
                        let item1 = AutoCompleteItem(result: AutoCompleteResult(name: "test"), type: AutoCompleteType.username, match: match)
                        let items = [item1]
                        vc.dataSource.items = items
                        vc.tableView.reloadData()

                        let expectedCell = vc.dataSource.tableView(vc.tableView, cellForRowAt: IndexPath(row: 0, section: 0))

                        expect(expectedCell).toNot(beNil())
                        expect(expectedCell).to(beAKindOf(AutoCompleteCell.self))
                    }
                }
            }
        }
    }
}
