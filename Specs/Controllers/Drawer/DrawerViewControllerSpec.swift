////
///  DrawerViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class DrawerViewControllerSpec: QuickSpec {
    override func spec() {
        describe("DrawerViewController") {
            describe("nib") {
                var subject: DrawerViewController!
                beforeEach {
                    subject = DrawerViewController()
                    showController(subject)
                }

                it("IBOutlets are not nil") {
                    expect(subject.tableView).toNot(beNil())
                    expect(subject.navigationBar).toNot(beNil())
                }

                it("sets up the collectionView's delegate and dataSource") {
                    subject.viewDidLoad()
                    subject.viewWillAppear(false)
                    let delegate = subject.tableView.delegate! as! DrawerViewController
                    let dataSource = subject.tableView.dataSource! as! DrawerViewDataSource

                    expect(delegate).to(equal(subject))
                    expect(dataSource).to(equal(subject.dataSource))
                }
            }

            describe("viewDidLoad") {
                var subject: DrawerViewController!
                beforeEach {
                    subject = DrawerViewController()
                    showController(subject)
                }

                it("registers cells") {
                    subject.viewWillAppear(false) // required because the datasource is not setup until viewWillAppear
                    expect(subject.tableView).to(haveRegisteredIdentifier(DrawerCell.reuseIdentifier))
                }
            }

            describe("appearance") {
                validateAllSnapshots(named: "DrawerViewController") { return DrawerViewController() }
            }
        }
    }
}
