////
///  DrawerViewDataSourceSpec.swift
//

@testable import Ello
import Quick
import Nimble


class DrawerViewDataSourceSpec: QuickSpec {
    override func spec() {

        context("UITableViewDataSource") {

            describe("tableView(_:numberOfrowsInSection:)") {

                it("returns 7") {
                    let dataSource = DrawerViewDataSource()
                    expect(dataSource.tableView(UITableView(frame: .zero), numberOfRowsInSection: 0)) == 5
                }
            }

            describe("itemForIndexPath(:)") {

                describe("has the correct items") {
                    let expectations: [DrawerItem] = [
                        DrawerItem(name: InterfaceString.Drawer.Store, type: .external("http://ello.threadless.com/")),
                        DrawerItem(name: InterfaceString.Drawer.Invite, type: .invite),
                        DrawerItem(name: InterfaceString.Drawer.Help, type: .external("https://ello.co/wtf/")),
                        DrawerItem(name: InterfaceString.Drawer.Logout, type: .logout),
                        DrawerItem(name: InterfaceString.Drawer.Version, type: .version),
                    ]
                    let dataSource = DrawerViewDataSource()
                    for (row, expectation) in expectations.enumerated() {
                        it("should have the correct item at index \(row)") {
                            let item = dataSource.itemForIndexPath(IndexPath(row: row, section: 0))
                            if let item = item {
                                expect(item.name) == expectation.name
                                expect("\(item.type)") == "\(expectation.type)"
                            }
                            else {
                                fail("no item at index \(row)")
                            }
                        }
                    }
                }
            }
        }
    }
}
