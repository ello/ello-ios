////
///  OmnibarScreenSpec.swift
//

@testable import Ello
import Quick
import Nimble


class OmnibarScreenMockDelegate : OmnibarScreenDelegate {
    var didGoBack = false
    var didPresentController = false
    var didDismissController = false
    var didPushController = false
    var submitted = false
    var hasBuyButtonURL = false

    func omnibarCancel() {
        didGoBack = true
    }
    func omnibarPushController(_ controller: UIViewController) {
        didPushController = true
    }
    func omnibarPresentController(_ controller : UIViewController) {
        didPresentController = true
    }
    func omnibarDismissController() {
        didDismissController = true
    }
    func omnibarSubmitted(_ regions: [OmnibarRegion], buyButtonURL: URL?) {
        submitted = true
        hasBuyButtonURL = buyButtonURL != nil
    }
}


enum RegionExpectation {
    case text(String)
    case image
    case spacer

    func matches(_ region: OmnibarRegion) -> Bool {
        switch (self, region) {
        case (.text, .attributedText):
            if case let .text(text) = self {
                return region.text!.string == text
            }
            return false
        case (.image, .image): return true
        case (.image, .imageData): return true
        case (.spacer, .spacer): return true
        default: return false
        }
    }
}


class OmnibarScreenSpec: QuickSpec {
    override func spec() {
        var subject : OmnibarScreen!
        var delegate : OmnibarScreenMockDelegate!

        beforeEach {
            let controller = UIViewController()
            subject = OmnibarScreen(frame: UIScreen.main.bounds)
            delegate = OmnibarScreenMockDelegate()
            subject.delegate = delegate
            controller.view.addSubview(subject)

            showController(controller)
        }

        describe("OmnibarScreen") {
            it("should use the '.Twitter' keyboard") {
                expect(subject.textView.keyboardType) == UIKeyboardType.twitter
            }

            describe("tapping the avatar") {
                it("should push the profile VC on to the navigation controller") {
                    subject.currentUser = User.stub(["id": "1"])
                    subject.profileImageTapped()
                    expect(delegate.didPushController) == true
                }
            }

            describe("pressing add image") {
                beforeEach {
                    subject.addImageAction()
                }
                it("should open an image selector") {
                    expect(delegate.didPresentController) == true
                }
            }

            describe("OmnibarScreenProtocol methods") {
                context("var delegate: OmnibarScreenDelegate?") {
                    it("sets the delegate") {
                        subject.delegate = delegate
                        expect(ObjectIdentifier(subject.delegate!)) == ObjectIdentifier(delegate)
                    }
                }
                context("var title: String") {
                    it("sets the navigation title") {
                        subject.title = "title"
                        expect(subject.navigationItem.title) == "title"
                    }
                }
                context("var submitTitle: String") {
                    it("sets the button title") {
                        subject.submitTitle = "post here"
                        expect(subject.tabbarSubmitButton.title(for: .normal)) == "post here"
                        expect(subject.keyboardSubmitButton.title(for: .normal)) == "post here"
                    }
                }
                context("var isComment: Bool") {
                    context("when false") {
                        beforeEach {
                            subject.isComment = false
                        }
                        it("should show the buyButton") {
                            expect(subject.buyButton.isHidden) == false
                        }
                    }
                    context("when true") {
                        beforeEach {
                            subject.isComment = true
                        }
                        it("should hide the buyButton") {
                            expect(subject.buyButton.isHidden) == true
                        }
                    }
                }
                context("var avatarURL: URL?") {
                    it("should set the button image (to nil)") {
                        let image = UIImage()
                        subject.avatarButton.setImage(image, for: .normal)
                        subject.avatarURL = URL(string: "http://www.example1.com")! as URL
                        subject.avatarURL = nil  // value needs to *change* for this to work
                        expect(subject.avatarButton.image(for: .normal)).to(beNil())
                    }
                }
                context("var avatarImage: UIImage?") {
                    it("should set the button image") {
                        let image = UIImage()
                        subject.avatarImage = image
                        expect(subject.avatarButton.image(for: .normal)) == image
                    }
                }
                context("var currentUser: User?") {
                    it("should set the user") {
                        subject.currentUser = User.stub(["id": "12345"])
                        expect(subject.currentUser?.id) == "12345"
                    }
                }
                context("var canGoBack: Bool") {
                    context("when true") {
                        it("should show the navigationBar") {
                            subject.canGoBack = true
                            subject.layoutIfNeeded()
                            expect(subject.navigationBar.frame.height) > 0
                        }
                        it("should position the avatarButton and toolbarButtonViews") {
                            subject.canGoBack = false
                            subject.layoutIfNeeded()
                            let toolbarY = subject.toolbarButtonViews[0].frame.minY
                            let avatarY = subject.avatarButton.frame.minY

                            subject.canGoBack = true
                            subject.layoutIfNeeded()
                            expect(subject.avatarButton.frame.minY) > avatarY
                            for button in subject.toolbarButtonViews {
                                expect(button.frame.minY) > toolbarY
                            }
                        }
                    }
                    context("when false") {
                        it("should hide the navigationBar") {
                            subject.canGoBack = false
                            subject.layoutIfNeeded()
                            expect(subject.navigationBar.frame.height) <= 0
                        }
                        it("should position the avatarButton and toolbarButtonViews") {
                            subject.canGoBack = true
                            subject.layoutIfNeeded()
                            let toolbarY = subject.toolbarButtonViews[0].frame.minY
                            let avatarY = subject.avatarButton.frame.minY

                            subject.canGoBack = false
                            subject.layoutIfNeeded()
                            expect(subject.avatarButton.frame.minY) < avatarY
                            for button in subject.toolbarButtonViews {
                                expect(button.frame.minY) < toolbarY
                            }
                        }
                    }
                }
                context("var isEditing: Bool") {
                    context("when false") {
                        it("causes 'x' button to delete") {
                            subject.isEditing = false
                            subject.regions = [.text("foo")]
                            expect(subject.canPost()) == true
                            subject.cancelEditingAction()
                            expect(delegate.didPresentController) == true
                            expect(delegate.didGoBack) == false
                        }
                    }
                    context("when true") {
                        it("causes 'x' button to cancel (when true)") {
                            subject.isEditing = true
                            subject.regions = [.text("foo")]
                            expect(subject.canPost()) == true
                            subject.cancelEditingAction()
                            expect(delegate.didPresentController) == false
                            expect(delegate.didGoBack) == true
                        }
                    }
                }
                context("func reportError(title: String, error: NSError)") {
                    context("when passing an NSError") {
                        it("should reportError") {
                            subject.reportError("foo", error: NSError(domain: ElloErrorDomain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: "failure"]))
                            expect(delegate.didPresentController) == true
                        }
                    }
                }
                context("func reportError(title: String, errorMessage: String)") {
                    context("when passing a String") {
                        it("should reportError") {
                            subject.reportError("foo", errorMessage: "bar")
                            expect(delegate.didPresentController) == true
                        }
                    }
                }
                context("func startEditing()") {
                    context("if the only region is text") {
                        it("should set the currentTextPath.row to 0") {
                            subject.currentTextPath = nil
                            subject.regions = [.text("")]
                            subject.startEditing()
                            expect(subject.currentTextPath?.row) == 0
                        }
                    }
                    context("if the first region is an image") {
                        it("should set the currentTextPath.row to 2") {
                            subject.currentTextPath = nil
                            subject.regions = [.image(UIImage()), .text("")]
                            subject.startEditing()
                            expect(subject.currentTextPath?.row) == 2  // image, spacer, text
                        }
                    }
                    context("if the only region is text and image") {
                        it("should not set the currentTextPath") {
                            subject.currentTextPath = nil
                            subject.regions = [.text(""), .image(UIImage())]
                            subject.startEditing()
                            expect(subject.currentTextPath?.row) == 0  // text, spacer, image, spacer, text
                        }
                    }
                }
                context("func startEditingLast()") {
                    context("if the only region is text") {
                        it("should set the currentTextPath.row to 0") {
                            subject.currentTextPath = nil
                            subject.regions = [.text("")]
                            subject.startEditingLast()
                            expect(subject.currentTextPath?.row) == 0
                        }
                    }
                    context("if the first region is an image") {
                        it("should set the currentTextPath.row to 2") {
                            subject.currentTextPath = nil
                            subject.regions = [.image(UIImage()), .text("")]
                            subject.startEditingLast()
                            expect(subject.currentTextPath?.row) == 2  // image, spacer, text
                        }
                    }
                    context("if the only region is text and image") {
                        it("should not set the currentTextPath") {
                            subject.currentTextPath = nil
                            subject.regions = [.text(""), .image(UIImage())]
                            subject.startEditingLast()
                            expect(subject.currentTextPath?.row) == 4  // text, image, spacer, text
                        }
                    }
                }
                context("func startEditingAtPath()") {
                    it("should set the currentTextPath") {
                        subject.currentTextPath = nil
                        subject.regions = [.image(UIImage()), .text("")]
                        subject.startEditingAtPath(IndexPath(row: 2, section: 0))
                        expect(subject.currentTextPath?.row) == 2
                    }
                    it("should not set the currentTextPath") {
                        subject.currentTextPath = nil
                        subject.regions = [.image(UIImage()), .text("")]
                        subject.startEditingAtPath(IndexPath(row: 1, section: 0))
                        expect(subject.currentTextPath).to(beNil())
                    }
                }
                context("func stopEditing()") {
                    it("should set the currentTextPath to nil") {
                        subject.regions = [.text("")]
                        subject.startEditing()
                        expect(subject.currentTextPath?.row).notTo(beNil())
                        subject.stopEditing()
                        expect(subject.currentTextPath?.row).to(beNil())
                    }
                    it("should remove empty regions") {
                        subject.regions = [.text(""), .image(UIImage()), .text("")]
                        subject.startEditing()
                        subject.stopEditing()
                        expect(subject.regions.count) == 2
                        expect(RegionExpectation.image.matches(subject.regions[0])) == true
                        expect(RegionExpectation.text("").matches(subject.regions[1])) == true
                    }
                }
                context("func updateButtons()") {
                    context("if posts are empty") {
                        beforeEach {
                            subject.regions = [OmnibarRegion]()
                            expect(subject.canPost()) == false
                            subject.updateButtons()
                        }
                        it("should disable posting") {
                            expect(subject.keyboardSubmitButton.isEnabled) == false
                            expect(subject.tabbarSubmitButton.isEnabled) == false
                        }
                        it("should disable buyButton") {
                            expect(subject.buyButton.isEnabled) == false
                        }
                    }
                    context("if posts have text") {
                        beforeEach {
                            subject.regions = [.text("test")]
                            subject.updateButtons()
                        }
                        it("should enable posting") {
                            expect(subject.keyboardSubmitButton.isEnabled) == true
                            expect(subject.tabbarSubmitButton.isEnabled) == true
                        }
                        it("should disable buyButton") {
                            expect(subject.buyButton.isEnabled) == false
                        }
                    }
                    context("if posts have text and images") {
                        beforeEach {
                            subject.regions = [.text("test"), .image(UIImage())]
                            subject.updateButtons()
                        }
                        it("should enable posting") {
                            expect(subject.keyboardSubmitButton.isEnabled) == true
                            expect(subject.tabbarSubmitButton.isEnabled) == true
                        }
                        it("should enable buyButton") {
                            expect(subject.buyButton.isEnabled) == true
                        }
                    }
                    context("if reordering and posts have text") {
                        beforeEach {
                            subject.regions = [.text("test")]
                            subject.reorderingTable(true)
                            subject.updateButtons()
                        }
                        it("should disable posting") {
                            expect(subject.keyboardSubmitButton.isEnabled) == false
                            expect(subject.tabbarSubmitButton.isEnabled) == false
                        }
                        it("should enable cancelling") {
                            expect(subject.cancelButton.isEnabled) == true
                        }
                        it("should disable buyButton button") {
                            expect(subject.buyButton.isEnabled) == false
                        }
                    }
                    context("if reordering and posts have text and images") {
                        beforeEach {
                            subject.regions = [.text("test"), .image(UIImage())]
                            subject.reorderingTable(true)
                            subject.updateButtons()
                        }
                        it("should disable posting") {
                            expect(subject.keyboardSubmitButton.isEnabled) == false
                            expect(subject.tabbarSubmitButton.isEnabled) == false
                        }
                        it("should enable cancelling") {
                            expect(subject.cancelButton.isEnabled) == true
                        }
                        it("should disable buyButton button") {
                            expect(subject.buyButton.isEnabled) == false
                        }
                    }
                    context("if not reordering") {
                        beforeEach {
                            subject.regions = [.text("test")]
                            subject.reorderingTable(false)
                            subject.updateButtons()
                        }
                        it("should enable cancelling") {
                            expect(subject.cancelButton.isEnabled) == true
                        }
                    }
                }
                describe("var regions: [OmnibarRegion]") {
                    context("setting to empty array") {
                        it("should set it to one text region") {
                            subject.regions = [OmnibarRegion]()
                            expect(subject.regions.count) == 1
                            expect(subject.regions[0].isText) == true
                            expect(subject.regions[0].empty) == true
                        }
                        it("should disable buyButton") {
                            expect(subject.buyButton.isEnabled) == false
                        }
                    }
                    context("setting to one text region array") {
                        beforeEach {
                            subject.regions = [.text("testing")]
                        }
                        it("should set it to one text region") {
                            expect(subject.regions.count) == 1
                            expect(subject.regions[0].isText) == true
                            expect(subject.regions[0].empty) == false
                        }
                        it("should disable buyButton") {
                            expect(subject.buyButton.isEnabled) == false
                        }
                    }
                    context("setting to one image region") {
                        beforeEach {
                            subject.regions = [.image(UIImage())]
                        }
                        it("generates a text region") {
                            expect(subject.regions.count) == 2
                            expect(subject.regions[0].isImage) == true
                            expect(subject.regions[1].isText) == true
                            expect(subject.regions[1].text?.string) == ""
                        }
                        it("should enable buyButton") {
                            expect(subject.buyButton.isEnabled) == true
                        }
                    }
                }
            }

            describe("generating editableRegions") {
                let expectationRules: [(String, [OmnibarRegion], [RegionExpectation])] = [
                    ("zero", [OmnibarRegion](), [.text("")]),
                    ("empty", [.text("")], [.text("")]),
                    ("text", [.text("some")], [.text("some")]),
                    ("image", [.image(UIImage())], [.image, .spacer, .text("")]),
                    ("image,text", [.image(UIImage()), .text("some")], [.image, .spacer, .text("some")]),
                    ("text,image", [.text("some"), .image(UIImage())], [.text("some"), .spacer, .image, .spacer, .text("")]),
                    ("text,image,text", [.text("some"), .image(UIImage()), .text("more")], [.text("some"), .spacer, .image, .spacer, .text("more")]),
                    ("text,image,image", [.text("some"), .image(UIImage()), .image(UIImage())], [.text("some"), .spacer, .image, .spacer, .image, .spacer, .text("")]),
                    ("text,image,image,text", [.text("some"), .image(UIImage()), .image(UIImage()), .text("")], [.text("some"), .spacer, .image, .spacer, .image, .spacer, .text("")]),
                    ("image,text,image", [.image(UIImage()), .text("some"), .image(UIImage())], [.image, .spacer, .text("some"), .spacer, .image, .spacer, .text("")]),
                    ("text,image,image,image,text,image,image",
                        [.text("some"), .image(UIImage()), .image(UIImage()), .image(UIImage()), .text("text"), .image(UIImage()), .image(UIImage())],
                        [.text("some"), .spacer, .image, .spacer, .image, .spacer, .image, .spacer, .text("text"), .spacer, .image, .spacer, .image, .spacer, .text("")]
                    ),
                ]
                for (name, regions, expectations) in expectationRules {
                    it("should correctly generate for \(name) conditions") {
                        subject.regions = regions

                        let editableRegions = subject.editableRegions
                        expect(editableRegions.count) == expectations.count
                        for (index, expectation) in expectations.enumerated() {
                            let (_, region) = editableRegions[index]
                            expect(expectation.matches(region)) == true
                        }
                    }
                }
            }

            describe("generating reorderableRegions") {
                let expectationRules: [(String, [OmnibarRegion], [RegionExpectation])] = [
                    ("empty", [.text("")],[RegionExpectation]()),
                    ("text", [.text("some")],[.text("some")]),
                    ("text with newlines", [.text("some\ntext")],[.text("some\ntext")]),
                    ("image,empty", [.image(UIImage()), .text("")],[.image]),
                    ("image,text", [.image(UIImage()), .text("some")],[.image,.text("some")]),
                    ("text,image,empty", [.text("some"), .image(UIImage()),.text("")],[.text("some"),.image]),
                    ("text,image,text", [.text("some"), .image(UIImage()),.text("text")],[.text("some"),.image,.text("text")]),
                    ("text with newlines,image,text", [.text("some\n\ntext"), .image(UIImage()), .text("more")],[.text("some\n\ntext"),.image,.text("more")]),
                    ("text,image,image,empty", [.text("some"), .image(UIImage()), .image(UIImage()), .text("")],[.text("some"),.image,.image]),
                    ("text,image,image,text", [.text("some"), .image(UIImage()), .image(UIImage()), .text("more")],[.text("some"),.image,.image,.text("more")]),
                    ("text,image,image,text w newlines", [.text("some"), .image(UIImage()), .image(UIImage()), .text("more\nlines")],[.text("some"),.image,.image,.text("more\nlines")]),
                    ("image,text,image,empty", [.image(UIImage()), .text("some"), .image(UIImage()), .text("")],[.image,.text("some"),.image]),
                    ("image,text,image,text", [.image(UIImage()), .text("some"), .image(UIImage()), .text("text")],[.image,.text("some"),.image,.text("text")]),
                    ("text,image,image,image,text,image,text",
                        [.text("some"), .image(UIImage()), .image(UIImage()), .image(UIImage()), .text("text"), .image(UIImage()), .image(UIImage()),.text("some")],
                        [.text("some"), .image, .image, .image, .text("text"), .image, .image, .text("some")]
                    ),
                ]
                for (name, regions, expectations) in expectationRules {
                    it("should correctly generate for \(name) conditions") {
                        subject.regions = regions

                        subject.reorderingTable(true)
                        let editableRegions = subject.reorderableRegions
                        expect(editableRegions.count) == expectations.count
                        for (index, expectation) in expectations.enumerated() {
                            let (_, region) = editableRegions[index]
                            expect(expectation.matches(region)) == true
                        }
                    }
                }
            }

            describe("generating editableRegions") {
                let expectationRules: [(String, [OmnibarRegion], [RegionExpectation])] = [
                    ("empty", [OmnibarRegion](),[.text("")]),
                    ("text", [.text("some")],[.text("some")]),
                    ("text,text", [.text("some\ntext")],[.text("some\ntext")]),
                    ("image,empty", [.image(UIImage())],[.image, .spacer, .text("")]),
                    ("image,text", [.image(UIImage()),.text("some")],[.image, .spacer, .text("some")]),
                    ("text,image,empty", [.text("some"),.image(UIImage())],[.text("some"), .spacer, .image, .spacer,.text("")]),
                    ("text with newlines,image,text", [.text("some\n\ntext"),.image(UIImage()),.text("more")],[.text("some\n\ntext"), .spacer, .image, .spacer, .text("more")]),
                    ("text,image,image,empty", [.text("some"),.image(UIImage()),.image(UIImage())],[.text("some"), .spacer, .image, .spacer, .image, .spacer, .text("")]),
                    ("text,image,image,text", [.text("some"),.image(UIImage()),.image(UIImage()),.text("more\nlines")],[.text("some"), .spacer, .image, .spacer, .image, .spacer, .text("more\nlines")]),
                    ("image,text,image,empty", [.image(UIImage()),.text("some"),.image(UIImage())],[.image, .spacer, .text("some"), .spacer, .image, .spacer, .text("")]),
                    ("text,image,image,image,text,image,text",
                        [.text("some"), .image(UIImage()), .image(UIImage()), .image(UIImage()), .text("text"), .image(UIImage()), .image(UIImage()), .text("some")],
                        [.text("some"), .spacer, .image, .spacer, .image, .spacer, .image, .spacer, .text("text"), .spacer, .image, .spacer, .image, .spacer, .text("some")]
                    ),
                ]
                for (name, regions, expectations) in expectationRules {
                    it("should correctly generate for \(name) conditions") {
                        subject.reorderableRegions = regions.map { (nil, $0) }

                        subject.reorderingTable(false)
                        let editableRegions = subject.editableRegions
                        expect(editableRegions.count) == expectations.count
                        for (index, expectation) in expectations.enumerated() {
                            let (_, region) = editableRegions[index]
                            expect(expectation.matches(region)) == true
                        }
                    }
                }
            }

            describe("deletable regions") {
                let expectations: [(String, OmnibarRegion, Bool)] = [
                    ("empty", .text(""), false),
                    ("text", .text("text"), true),
                    ("spacer", .spacer, false),
                    ("image", .image(UIImage()), true),
                ]
                for (name, region, expected) in expectations {
                    it("\(name) should \(expected ? "be" : "not be") editable") {
                        expect(region.editable) == expected
                    }
                }
            }

            describe("deleting regions") {
                let expectationRules: [(String, [OmnibarRegion], IndexPath, [RegionExpectation])] = [
                    ("text", [.text("some")], IndexPath(row: 0, section: 0),                               [.text("")]),
                    ("image", [.image(UIImage())], IndexPath(row: 0, section: 0),                 [.text("")]),
                    ("image,text(0)", [.image(UIImage()), .text("some")], IndexPath(row: 0, section: 0),  [.text("some")]),
                    ("image,text(1)", [.image(UIImage()), .text("some")], IndexPath(row: 2, section: 0),  [.image, .spacer, .text("")]),
                    ("text,image(0)", [.text("some"), .image(UIImage())], IndexPath(row: 0, section: 0),  [.image, .spacer, .text("")]),
                    ("text,image(1)", [.text("some"), .image(UIImage())], IndexPath(row: 2, section: 0),  [.text("some")]),
                    ("text,image,text(0)", [.text("some"), .image(UIImage()), .text("more")],IndexPath(row: 0, section: 0), [.image, .spacer, .text("more")]),
                    ("text,image,text(1a)", [.text("some"), .image(UIImage()), .text("more")],IndexPath(row: 2, section: 0), [.text("some\n\nmore")]),
                    ("text,image,text(1b)", [.text("some\n"), .image(UIImage()), .text("more")],IndexPath(row: 2, section: 0), [.text("some\n\nmore")]),
                    ("text,image,text(1c)", [.text("some\n\n"), .image(UIImage()), .text("more")],IndexPath(row: 2, section: 0), [.text("some\n\nmore")]),
                    ("text,image,text(1d)", [.text("some\n\n\n"), .image(UIImage()), .text("more")],IndexPath(row: 2, section: 0), [.text("some\n\n\nmore")]),
                    ("text,image,text(2)", [.text("some"), .image(UIImage()), .text("more")], IndexPath(row: 4, section: 0), [.text("some"), .spacer, .image, .spacer, .text("")]),
                    ("text,image,image(0)", [.text("some"), .image(UIImage()), .image(UIImage())], IndexPath(row: 0, section: 0), [.image, .spacer, .image, .spacer, .text("")]),
                    ("text,image,image(1)", [.text("some"), .image(UIImage()), .image(UIImage())], IndexPath(row: 2, section: 0), [.text("some"), .spacer, .image, .spacer, .text("")]),
                    ("text,image,image(2)", [.text("some"), .image(UIImage()), .image(UIImage())], IndexPath(row: 4, section: 0), [.text("some"), .spacer, .image, .spacer, .text("")]),
                    ("text,image,image,text(0)", [.text("some"), .image(UIImage()), .image(UIImage()), .text("text")], IndexPath(row: 0, section: 0), [.image, .spacer, .image, .spacer, .text("text")]),
                    ("text,image,image,text(1)", [.text("some"), .image(UIImage()), .image(UIImage()), .text("text")], IndexPath(row: 2, section: 0), [.text("some"), .spacer, .image, .spacer, .text("text")]),
                    ("text,image,image,text(2)", [.text("some"), .image(UIImage()), .image(UIImage()), .text("text")], IndexPath(row: 4, section: 0), [.text("some"), .spacer, .image, .spacer, .text("text")]),
                    ("text,image,image,text(3)", [.text("some"), .image(UIImage()), .image(UIImage()), .text("text")], IndexPath(row: 6, section: 0), [.text("some"), .spacer, .image, .spacer, .image, .spacer, .text("")]),
                    ("image,text,image(0)", [.image(UIImage()), .text("some"), .image(UIImage())], IndexPath(row: 0, section: 0), [.text("some"), .spacer, .image, .spacer, .text("")]),
                    ("image,text,image(1)", [.image(UIImage()), .text("some"), .image(UIImage())], IndexPath(row: 2, section: 0), [.image, .spacer, .image, .spacer, .text("")]),
                    ("image,text,image(2)", [.image(UIImage()), .text("some"), .image(UIImage())], IndexPath(row: 4, section: 0), [.image, .spacer, .text("some")]),
                    ("text,image,image,image,text,image,image(0)",
                        [.text("some"), .image(UIImage()), .image(UIImage()), .image(UIImage()), .text("text"), .image(UIImage()), .image(UIImage())],
                        IndexPath(row: 0, section: 0),
                        [.image, .spacer, .image, .spacer, .image, .spacer, .text("text"), .spacer, .image, .spacer, .image, .spacer, .text("")]
                    ),
                    ("text,image,image,image,text,image,image(1)",
                        [.text("some"), .image(UIImage()), .image(UIImage()), .image(UIImage()), .text("text"), .image(UIImage()), .image(UIImage())],
                        IndexPath(row: 2, section: 0),
                        [.text("some"), .spacer, .image, .spacer, .image, .spacer, .text("text"), .spacer, .image, .spacer, .image, .spacer, .text("")]
                    ),
                    ("text,image,image,image,text,image,image(2)",
                        [.text("some"), .image(UIImage()), .image(UIImage()), .image(UIImage()), .text("text"), .image(UIImage()), .image(UIImage())],
                        IndexPath(row: 4, section: 0),
                        [.text("some"), .spacer, .image, .spacer, .image, .spacer, .text("text"), .spacer, .image, .spacer, .image, .spacer, .text("")]
                    ),
                    ("text,image,image,image,text,image,image(3)",
                        [.text("some"), .image(UIImage()), .image(UIImage()), .image(UIImage()), .text("text"), .image(UIImage()), .image(UIImage())],
                        IndexPath(row: 6, section: 0),
                        [.text("some"), .spacer, .image, .spacer, .image, .spacer, .text("text"), .spacer, .image, .spacer, .image, .spacer, .text("")]
                    ),
                    ("text,image,image,image,text,image,image(4)",
                        [.text("some"), .image(UIImage()), .image(UIImage()), .image(UIImage()), .text("text"), .image(UIImage()), .image(UIImage())],
                        IndexPath(row: 8, section: 0),
                        [.text("some"), .spacer, .image, .spacer, .image, .spacer, .image, .spacer, .image, .spacer, .image, .spacer, .text("")]
                    ),
                    ("text,image,image,image,text,image,image(5)",
                        [.text("some"), .image(UIImage()), .image(UIImage()), .image(UIImage()), .text("text"), .image(UIImage()), .image(UIImage())],
                        IndexPath(row: 10, section: 0),
                        [.text("some"), .spacer, .image, .spacer, .image, .spacer, .image, .spacer, .text("text"), .spacer, .image, .spacer, .text("")]
                    ),
                    ("text,image,image,image,text,image,image(6)",
                        [.text("some"), .image(UIImage()), .image(UIImage()), .image(UIImage()), .text("text"), .image(UIImage()), .image(UIImage())],
                        IndexPath(row: 12, section: 0),
                        [.text("some"), .spacer, .image, .spacer, .image, .spacer, .image, .spacer, .text("text"), .spacer, .image, .spacer, .text("")]
                    ),
                ]
                for (name, regions, path, expectations) in expectationRules {
                    it("should correctly delete for \(name) at row \(path.row)") {
                        subject.regions = regions

                        if subject.tableView(UITableView(), canEditRowAt: path) {
                            subject.deleteEditableAtIndexPath(path as IndexPath)
                            let editableRegions = subject.editableRegions
                            expect(editableRegions.count) == expectations.count
                            for (index, expectation) in expectations.enumerated() {
                                let (_, region) = editableRegions[index]
                                expect(expectation.matches(region)) == true
                            }
                        }
                        else {
                            fail("cannot edit at index path \(path)")
                        }
                    }
                }
            }

            describe("reordering regions") {
                let expectationRules: [(String, [OmnibarRegion], (IndexPath, IndexPath), [RegionExpectation])] = [
                    ("image,text(0)",
                        [.image(UIImage()), .text("some")],
                        (IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)),
                        [.text("some"),.spacer,.image,.spacer,.text("")]
                    ),
                    ("image,text(1)",
                        [.image(UIImage()), .text("some")],
                        (IndexPath(row: 1, section: 0), IndexPath(row: 0, section: 0)),
                        [.text("some"),.spacer,.image,.spacer,.text("")]
                    ),

                    ("text,image,text(0)",
                        [.text("some"),.spacer,.image(UIImage()),.text("text")],
                        (IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)),
                        [.image,.spacer,.text("some\n\ntext")]
                    ),
                    ("text,image,text(1)",
                        [.text("some"),.spacer,.image(UIImage()),.text("text")],
                        (IndexPath(row: 0, section: 0), IndexPath(row: 2, section: 0)),
                        [.image,.spacer,.text("text\n\nsome")]
                    ),
                    ("text,image,text(2)",
                        [.text("some"),.spacer,.image(UIImage()),.text("text")],
                        (IndexPath(row: 1, section: 0), IndexPath(row: 0, section: 0)),
                        [.image,.spacer,.text("some\n\ntext")]
                    ),
                    ("text,image,text(3)",
                        [.text("some"),.spacer,.image(UIImage()),.text("text")],
                        (IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)),
                        [.text("some\n\ntext"),.spacer,.image,.spacer,.text("")]
                    ),
                    ("text,image,text(4)",
                        [.text("some"),.image(UIImage()),.text("text")],
                        (IndexPath(row: 2, section: 0), IndexPath(row: 0, section: 0)),
                        [.text("text\n\nsome"),.spacer,.image,.spacer,.text("")]
                    ),
                    ("text,image,text(5)",
                        [.text("some"),.image(UIImage()),.text("text")],
                        (IndexPath(row: 2, section: 0), IndexPath(row: 1, section: 0)),
                        [.text("some\n\ntext"),.spacer,.image,.spacer,.text("")]
                    ),

                    ("text with two trailing newlines,image,text",
                        [.text("some\n\n"),.image(UIImage()), .text("more")],
                        (IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)),
                        [.image,.spacer,.text("some\n\nmore")]
                    ),
                    ("text with many trailing newlines,image,text",
                        [.text("some\n\n\n\n"),.image(UIImage()), .text("more")],
                        (IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)),
                        [.image,.spacer,.text("some\n\n\n\nmore")]
                    ),
                    ("text with one trailing newline,image,text",
                        [.text("some\n"),.image(UIImage()), .text("more")],
                        (IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)),
                        [.image,.spacer,.text("some\n\nmore")]
                    ),

                    ("text with newlines,image,text(0)",
                        [.text("some\n\ntext"),.image(UIImage()), .text("more")],
                        (IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)),
                        [.image,.spacer,.text("some\n\ntext\n\nmore")]
                    ),
                    ("text with newlines,image,text(1)",
                        [.text("some\n\ntext"),.image(UIImage()), .text("more")],
                        (IndexPath(row: 0, section: 0), IndexPath(row: 2, section: 0)),
                        [.image,.spacer,.text("more\n\nsome\n\ntext")]
                    ),

                    ("text,image,image,empty(0)",
                        [.text("some"),.spacer,.image(UIImage()),.image(UIImage()), .text("")],
                        (IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)),
                        [.image,.spacer,.text("some"),.spacer,.image,.spacer,.text("")]
                    ),
                    ("text,image,image,empty(1)",
                        [.text("some"),.spacer,.image(UIImage()),.image(UIImage()), .text("")],
                        (IndexPath(row: 1, section: 0), IndexPath(row: 0, section: 0)),
                        [.image,.spacer,.text("some"),.spacer,.image,.spacer,.text("")]
                    ),
                    ("text,image,image,empty(2)",
                        [.text("some"),.spacer,.image(UIImage()),.image(UIImage()), .text("")],
                        (IndexPath(row: 2, section: 0), IndexPath(row: 0, section: 0)),
                        [.image,.spacer,.text("some"),.spacer,.image,.spacer,.text("")]
                    ),
                    ("text,image,image,empty(3)",
                        [.text("some"),.spacer,.image(UIImage()),.image(UIImage()), .text("")],
                        (IndexPath(row: 0, section: 0), IndexPath(row: 2, section: 0)),
                        [.image,.spacer,.image,.spacer,.text("some")]
                    ),

                    ("text,image,image,text(0)",
                        [.text("some"),.spacer,.image(UIImage()),.image(UIImage()), .text("more")],
                        (IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)),
                        [.image,.spacer,.text("some"),.spacer,.image,.spacer,.text("more")]
                    ),
                    ("text,image,image,text(1)",
                        [.text("some"),.spacer,.image(UIImage()),.image(UIImage()), .text("more")],
                        (IndexPath(row: 0, section: 0), IndexPath(row: 2, section: 0)),
                        [.image,.spacer,.image,.spacer,.text("some\n\nmore")]
                    ),
                    ("text,image,image,text(2)",
                        [.text("some"),.spacer,.image(UIImage()),.image(UIImage()), .text("more")],
                        (IndexPath(row: 0, section: 0), IndexPath(row: 3, section: 0)),
                        [.image,.spacer,.image,.spacer,.text("more\n\nsome")]
                    ),
                    ("text,image,image,text(3)",
                        [.text("some"),.spacer,.image(UIImage()),.image(UIImage()), .text("more")],
                        (IndexPath(row: 1, section: 0), IndexPath(row: 0, section: 0)),
                        [.image,.spacer,.text("some"),.spacer,.image,.spacer,.text("more")]
                    ),
                    ("text,image,image,text(4)",
                        [.text("some"),.spacer,.image(UIImage()),.image(UIImage()), .text("more")],
                        (IndexPath(row: 1, section: 0), IndexPath(row: 2, section: 0)),
                        [.text("some"),.spacer,.image,.spacer,.image,.spacer,.text("more")]
                    ),
                    ("text,image,image,text(5)",
                        [.text("some"),.spacer,.image(UIImage()),.image(UIImage()), .text("more")],
                        (IndexPath(row: 1, section: 0), IndexPath(row: 3, section: 0)),
                        [.text("some"),.spacer,.image,.spacer,.text("more"),.spacer,.image,.spacer,.text("")]
                    ),

                    ("text,image,image,text w newlines(0)",
                        [.text("some"),.spacer,.image(UIImage()),.image(UIImage()), .text("more\nlines")],
                        (IndexPath(row: 0, section: 0), IndexPath(row: 2, section: 0)),
                        [.image,.spacer,.image,.spacer,.text("some\n\nmore\nlines")]
                    ),
                    ("text,image,image,text w newlines(1)",
                        [.text("some"),.spacer,.image(UIImage()),.image(UIImage()), .text("more\nlines")],
                        (IndexPath(row: 0, section: 0), IndexPath(row: 3, section: 0)),
                        [.image,.spacer,.image,.spacer,.text("more\nlines\n\nsome")]
                    ),
                    ("text,image,image,text w newlines(2)",
                        [.text("some"),.spacer,.image(UIImage()),.image(UIImage()), .text("more\nlines")],
                        (IndexPath(row: 2, section: 0), IndexPath(row: 0, section: 0)),
                        [.image,.spacer,.text("some"),.spacer,.image,.spacer,.text("more\nlines")]
                    ),
                    ("text,image,image,text w newlines(3)",
                        [.text("some"),.spacer,.image(UIImage()),.image(UIImage()), .text("more\nlines")],
                        (IndexPath(row: 3, section: 0), IndexPath(row: 0, section: 0)),
                        [.text("more\nlines\n\nsome"),.spacer,.image,.spacer,.image,.spacer,.text("")]
                    ),
                ]
                for (name, regions, reorder, expectations) in expectationRules {
                    describe("for \(name) conditions (from \(reorder.0.row) to \(reorder.1.row))") {
                        beforeEach {
                            let (src, dest) = reorder
                            subject.regions = regions
                            subject.reorderingTable(true)
                            subject.tableView(UITableView(), moveRowAt: src, to: dest)
                            subject.reorderingTable(false)
                        }
                        it("should correctly reorder") {
                            let editableRegions = subject.editableRegions
                            expect(editableRegions.count) == expectations.count
                            for (index, expectation) in expectations.enumerated() {
                                let (_, region) = editableRegions[index]
                                expect(expectation.matches(region)) == true
                            }
                        }
                    }
                }
            }

            describe("deleting regions while reordering") {
                let expectationRules: [(String, [OmnibarRegion], IndexPath, [RegionExpectation])] = [
                    ("text", [.text("some")], IndexPath(row: 0, section: 0),                               [.text("")]),
                    ("image", [.image(UIImage())], IndexPath(row: 0, section: 0),                 [.text("")]),
                    ("image,text(0)", [.image(UIImage()), .text("some")], IndexPath(row: 0, section: 0),  [.text("some")]),
                    ("image,text(1)", [.image(UIImage()), .text("some")], IndexPath(row: 1, section: 0),  [.image,.spacer,.text("")]),
                    ("text,image(0)", [.text("some"), .image(UIImage())], IndexPath(row: 0, section: 0),  [.image,.spacer,.text("")]),
                    ("text,image(1)", [.text("some"), .image(UIImage())], IndexPath(row: 1, section: 0),  [.text("some")]),
                    ("text,image,image(0)", [.text("some"), .image(UIImage()), .image(UIImage())], IndexPath(row: 0, section: 0), [.image,.spacer,.image,.spacer,.text("")]),
                    ("text,image,image(1)", [.text("some"), .image(UIImage()), .image(UIImage())], IndexPath(row: 1, section: 0), [.text("some"),.spacer,.image,.spacer,.text("")]),
                    ("text,image,image(2)", [.text("some"), .image(UIImage()), .image(UIImage())], IndexPath(row: 2, section: 0), [.text("some"),.spacer,.image,.spacer,.text("")]),
                ]
                for (name, regions, path, expectations) in expectationRules {
                    describe("for \(name) at row \(path.row)") {
                        let expectedBuyButton = expectations.reduce(false) { return $0 || $1.matches(.image(UIImage())) }
                        beforeEach {
                            subject.regions = regions
                            subject.reorderingTable(true)
                            subject.deleteReorderableAtIndexPath(path as IndexPath)
                            subject.reorderingTable(false)
                        }
                        it("should correctly delete") {
                            let editableRegions = subject.editableRegions
                            expect(editableRegions.count) == expectations.count
                            for (index, expectation) in expectations.enumerated() {
                                let (_, region) = editableRegions[index]
                                expect(expectation.matches(region)) == true
                            }
                        }

                        it("should set buyButton.enabled to \(expectedBuyButton)") {
                            expect(subject.buyButton.isEnabled) == expectedBuyButton
                        }
                    }
                }
                it("should end reordering if no more regions") {
                    subject.regions = [.text("some")]
                    subject.reorderingTable(true)
                    expect(subject.reordering) == true
                    subject.deleteReorderableAtIndexPath(IndexPath(row: 0, section: 0))
                    expect(subject.reordering) == false
                    expect(subject.regions.count) == 1
                    expect(RegionExpectation.text("").matches(subject.regions[0])) == true
                }
            }

            describe("adding images") {
                let expectationRules: [(String, [OmnibarRegion], [RegionExpectation])] = [
                    ("text", [.text("some")], [.text("some"),.spacer,.image,.spacer,.text("")]),
                    ("image", [.image(UIImage())], [.image,.spacer,.image,.spacer,.text("")]),
                    ("image,text", [.image(UIImage()), .text("some")], [.image,.spacer,.text("some"),.spacer,.image,.spacer,.text("")]),
                    ("text,image", [.text("some"), .image(UIImage())], [.text("some"),.spacer,.image,.spacer,.image,.spacer,.text("")]),
                ]
                for (name, regions, expectations) in expectationRules {
                    describe("for \(name)") {
                        beforeEach {
                            subject.regions = regions
                            subject.addImage(UIImage())
                        }
                        it("should correctly add an image") {
                            let editableRegions = subject.editableRegions
                            expect(editableRegions.count) == expectations.count
                            for (index, expectation) in expectations.enumerated() {
                                let (_, region) = editableRegions[index]
                                expect(expectation.matches(region)) == true
                            }
                        }
                        it("should enable buyButton") {
                            expect(subject.buyButton.isEnabled) == true
                        }
                    }
                }
            }
        }
    }
}
