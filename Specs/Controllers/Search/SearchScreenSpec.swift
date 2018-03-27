////
///  SearchScreenSpec.swift
//

@testable import Ello
import Quick
import Nimble


class MockSearchScreenDelegate: NSObject, SearchScreenDelegate {
    var searchFieldWasCleared = false
    func searchCanceled(){}
    func searchFieldCleared(){searchFieldWasCleared = true}
    func searchFieldChanged(_ text: String, isPostSearch: Bool){}
    func searchShouldReset(){}
    func toggleChanged(_ text: String, isPostSearch: Bool){}
    func findFriendsTapped(){}
    func backButtonTapped() {}
    func gridListToggled(sender: UIButton) {}
}

class SearchScreenSpec: QuickSpec {
    override func spec() {
        describe("SearchScreen") {
            var subject: SearchScreen!

            beforeEach {
                subject = SearchScreen()
                subject.showsFindFriends = true
                subject.frame = CGRect(origin: .zero, size: CGSize(width: 320, height: 568))
            }

            context("searching for people") {
                it("should set the search text to 'atsign' if the search field is empty") {
                    subject.searchField.text = ""
                    subject.onPeopleTapped()
                    expect(subject.searchField.text) == "@"
                }

                it("should set the search text to 'atsign' if the search field is null") {
                    subject.searchField.text = nil
                    subject.onPeopleTapped()
                    expect(subject.searchField.text) == "@"
                }

                it("should clear the search text if it was 'atsign' and you search for posts") {
                    subject.onPeopleTapped()
                    subject.searchField.text = "@"
                    subject.onPostsTapped()
                    expect(subject.searchField.text) == ""
                }
            }

            context("UITextFieldDelegate") {

                describe("textFieldShouldReturn(_:)") {

                    it("returns true") {
                        let shouldReturn = subject.textFieldShouldReturn(subject.searchField)

                        expect(shouldReturn) == true
                    }

                    it("hides keyboard") {
                        _ = subject.textFieldShouldReturn(subject.searchField)

                        expect(subject.searchField.isFirstResponder) == false
                    }
                }

                describe("textFieldShouldClear(_:)") {

                    it("returns true") {
                        let shouldReturn = subject.textFieldShouldClear(subject.searchField)

                        expect(shouldReturn) == true
                    }

                    it("calls search field cleared on it's delegate") {

                        let delegate = MockSearchScreenDelegate()
                        subject.delegate = delegate
                        _ = subject.textFieldShouldClear(subject.searchField)

                        expect(delegate.searchFieldWasCleared) == true
                    }

                    context("is search view") {

                        beforeEach {
                            subject = SearchScreen()
                            subject.showsFindFriends = true
                        }

                        it("shows find friends text") {
                            expect(Keyboard.shared.isActive) == false
                            _ = subject.textFieldShouldClear(subject.searchField)
                            expectValidSnapshot(subject)
                        }
                    }

                    context("is NOT search view") {

                        beforeEach {
                            subject = SearchScreen()
                            subject.showsFindFriends = false
                        }

                        it("hides find friends text") {
                            _ = subject.textFieldShouldClear(subject.searchField)
                            expectValidSnapshot(subject)
                        }
                    }
                }
            }
        }
    }
}
