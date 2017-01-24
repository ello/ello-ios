////
///  NewElloTabBarSpecs.swift
//

@testable import Ello
import Quick
import Nimble
import Nimble_Snapshots


class NewElloTabBarSpecs: QuickSpec {
    override func spec() {
        xdescribe("NewElloTabBar.ItemView") {
            let tests: [String: NewElloTabBar.Item] = [
                "should support a selected? title": NewElloTabBar.Item(alignment: .Left, display: .Title(InterfaceString.Following.Title), redDotHidden: true),
                "should support a selected? title with a red dot": NewElloTabBar.Item(alignment: .Left, display: .Title(InterfaceString.Following.Title), redDotHidden: false),
                "should support a selected? svg": NewElloTabBar.Item(alignment: .Left, display: .Image(.Bolt), redDotHidden: true),
                "should support a selected? svg with a red dot": NewElloTabBar.Item(alignment: .Left, display: .Image(.Bolt), redDotHidden: false),
            ]
            for (description, item) in tests {
                let unselectedDescription = description.stringByReplacingOccurrencesOfString("selected? ", withString: "")
                let selectedDescription = description.stringByReplacingOccurrencesOfString("selected? ", withString: "selected ")
                it(unselectedDescription) {
                    let subject = NewElloTabBar.ItemView(item: item)
                    subject.frame = CGRect(origin: .zero, size: subject.intrinsicContentSize())
                    subject.selected = false
                    expect(subject).to(haveValidSnapshot())
                }
                it(selectedDescription) {
                    let subject = NewElloTabBar.ItemView(item: item)
                    subject.frame = CGRect(origin: .zero, size: subject.intrinsicContentSize())
                    subject.selected = true
                    expect(subject).to(haveValidSnapshot())
                }
            }
        }
        xdescribe("NewElloTabBar") {
            it("should accept empty NewElloTabBar.Items") {
                let subject = NewElloTabBar()
                let items: [NewElloTabBar.Item] = []
                subject.items = items
                expect(subject.items.count) == 0
            }
            it("should accept some NewElloTabBar.Items") {
                let subject = NewElloTabBar()
                subject.items = [
                    NewElloTabBar.Item(alignment: .Left, display: .Title(InterfaceString.Following.Title), redDotHidden: true),
                    NewElloTabBar.Item(alignment: .Right, display: .Image(.Bolt), redDotHidden: false),
                ]

                expect(subject.items.count) == 2
                expect(subject.items[0].title) == InterfaceString.Following.Title
                expect(subject.items[1].interfaceImage) == .Bolt
            }
            describe("snapshots") {
                var subject: NewElloTabBar!

                beforeEach {
                    subject = NewElloTabBar()
                    subject.items = [
                        NewElloTabBar.Item(alignment: .Left, display: .Title(InterfaceString.FollowingStream.Title), redDotHidden: true),
                        NewElloTabBar.Item(alignment: .Left, display: .Title(InterfaceString.StarredStream.Title), redDotHidden: false),
                        NewElloTabBar.Item(alignment: .Left, display: .Title(InterfaceString.Discover.Title), redDotHidden: true),
                        NewElloTabBar.Item(alignment: .Right, display: .Image(.Bolt), redDotHidden: false),
                        NewElloTabBar.Item(alignment: .Right, display: .Image(.Search), redDotHidden: true),
                    ]
                }
                let tests: [String: CGSize] = [
                    "should be valid for iphone 4": CGSize(width: 320, height: 50),
                    "should be valid for iphone 4.7": CGSize(width: 375, height: 50),
                    "should be valid for iphone 5.5": CGSize(width: 414, height: 50),
                    "should be valid for ipad portrait": CGSize(width: 768, height: 50),
                    "should be valid for ipad landscape": CGSize(width: 1024, height: 50),
                ]
                for (description, size) in tests {
                    it(description) {
                        subject.frame.size = size
                        expect(subject).to(haveValidSnapshot())
                    }

                    let selections: [String: Int] = [
                        "following": 0,
                        "starred": 1,
                        "notifications": 2,
                        "search": 3,
                    ]
                    for (name, index) in selections {
                        it("\(description) selecting \(name)") {
                            subject.frame.size = size
                            subject.selectedIndex = index
                            expect(subject).to(haveValidSnapshot())
                        }
                    }
                }
            }
        }
    }
}
