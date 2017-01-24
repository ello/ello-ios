////
///  AutoCompleteViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class AutoCompleteViewControllerSpec: QuickSpec {
    override func spec() {
        describe("AutoCompleteViewController") {
            describe("nib") {

                var subject = AutoCompleteViewController()

                beforeEach {
                    subject = AutoCompleteViewController()
                    showController(subject)
                }

                it("IBOutlets are not nil") {
                    expect(subject.tableView).toNot(beNil())
                }

                it("sets up the tableView's delegate and dataSource") {
                    subject.viewDidLoad()
                    subject.viewWillAppear(false)
                    let delegate = subject.tableView.delegate! as! AutoCompleteViewController
                    let dataSource = subject.tableView.dataSource! as! AutoCompleteDataSource

                    expect(delegate).to(equal(subject))
                    expect(dataSource).to(equal(subject.dataSource))
                }
            }

            describe("viewDidLoad()") {

                var subject = AutoCompleteViewController()

                beforeEach {
                    subject = AutoCompleteViewController()
                    showController(subject)
                }

                it("styles the view") {
                    expect(subject.tableView.backgroundColor) == UIColor.black
                }

                it("registers cells") {
                    subject.viewWillAppear(false)
                    let match = AutoCompleteMatch(type: AutoCompleteType.username, range: (start:"test".startIndex..<"test".endIndex), text: "test")
                    subject.dataSource.items = [AutoCompleteItem(result: AutoCompleteResult(name: "test"), type: AutoCompleteType.emoji, match: match)]

                    expect(subject.tableView).to(haveRegisteredIdentifier(AutoCompleteCell.reuseIdentifier))
                }
            }
        }
    }
}
