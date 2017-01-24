////
///  AutoCompleteCellPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble

class AutoCompleteCellPresenterSpec: QuickSpec {
    override func spec() {
        describe("AutoCompleteCellPresenter") {
            context("username") {
                it("configures a AutoCompleteCell") {
                    let match = AutoCompleteMatch(type: AutoCompleteType.username, range: ("test".startIndex..<"test".endIndex), text: "test")
                    let result = AutoCompleteResult(name: "Billy", url: "http://www.example.com/avatar")
                    let item = AutoCompleteItem(result: result, type: AutoCompleteType.username, match: match)

                    let cell: AutoCompleteCell = AutoCompleteCell.loadFromNib()

                    AutoCompleteCellPresenter.configure(cell, item: item)

                    expect(cell.name.text) == "@Billy"
                    expect(cell.avatar.imageURL) == URL(string: "http://www.example.com/avatar")!
                    expect(cell.selectionStyle) == UITableViewCellSelectionStyle.none
                    expect(cell.name.textColor) == UIColor.white
                    expect(cell.name.font) == UIFont.defaultFont()
                    expect(cell.line.isHidden) == false
                    expect(cell.line.backgroundColor) == UIColor.grey3()
                }
            }

            context("emoji") {
                it("configures a AutoCompleteCell") {
                    let match = AutoCompleteMatch(type: AutoCompleteType.emoji, range: ("test".startIndex..<"test".endIndex), text: "test")
                    let result = AutoCompleteResult(name: "thumbsup", url: "http://www.example.com/emoji")
                    let item = AutoCompleteItem(result: result, type: AutoCompleteType.emoji, match: match)

                    let cell: AutoCompleteCell = AutoCompleteCell.loadFromNib()

                    AutoCompleteCellPresenter.configure(cell, item: item)

                    expect(cell.name.text) == ":thumbsup:"
                    expect(cell.avatar.imageURL) == URL(string: "http://www.example.com/emoji")!
                    expect(cell.selectionStyle) == UITableViewCellSelectionStyle.none
                    expect(cell.name.textColor) == UIColor.white
                    expect(cell.name.font) == UIFont.defaultFont()
                    expect(cell.line.isHidden) == false
                    expect(cell.line.backgroundColor) == UIColor.grey3()
                }
            }
        }
    }
}
