////
///  AutoComplete.swift
//

public struct AutoCompleteMatch: CustomStringConvertible, Equatable {

    public var description: String {
        return "type: \(self.type), range: \(self.range), text: \(self.text)"
    }

    public let type: AutoCompleteType
    public let range: Range<String.Index>
    public let text: String

    public init(type: AutoCompleteType, range: Range<String.Index>, text: String ){
        self.type = type
        self.range = range
        self.text = text
    }
}

public func == (lhs: AutoCompleteMatch, rhs: AutoCompleteMatch) -> Bool {
    return lhs.type == rhs.type && lhs.range == rhs.range && lhs.text == rhs.text
}

public enum AutoCompleteType: String, CustomStringConvertible {
    case Emoji = "Emoji"
    case Username = "Username"
    case Location = "Location"

    public var description: String {
        return self.rawValue
    }
}

public struct AutoComplete {

    public init(){}

    public func eagerCheck(text: String, location: Int) -> Bool {
        if location >= text.characters.count { return false }

        let wordStartIndex = getIndexOfWordStart(location, fromString: text)
        let wordEndIndex = text.startIndex.advancedBy(location)
        let char = text.substringWithRange(wordStartIndex..<wordStartIndex.advancedBy(1))
        let substr = text.substringWithRange(wordStartIndex..<wordEndIndex)
        if (substr.characters.split { $0 == ":" }).count > 1 {
            return false
        }
        return char == "@" || char == ":"
    }

    public func check(text: String, location: Int) -> AutoCompleteMatch? {
        if location >= text.characters.count { return .None }

        let wordStartIndex = getIndexOfWordStart(location, fromString: text)
        let wordEndIndex = text.startIndex.advancedBy(location)
        if wordStartIndex >= wordEndIndex { return .None }

        let range: Range<String.Index> = wordStartIndex...wordEndIndex
        let word = text.substringWithRange(range)
        if findUsername(word) {
            return AutoCompleteMatch(type: .Username, range: range, text: word)
        }
        else if findEmoji(word) {
            return AutoCompleteMatch(type: .Emoji, range: range, text: word)
        }

        return .None
    }
}

private let usernameRegex = Regex("([^\\w]|\\s|^)@(\\w+)")!
private let emojiRegex = Regex("([^\\w]|\\s|^):(\\w+)")!

private extension AutoComplete {

    func findUsername(text: String) -> Bool {
        return text =~ usernameRegex
    }

    func findEmoji(text: String) -> Bool {
        // this handles ':one:two'
        if (text.characters.split { $0 == ":" }).count > 1 {
            return false
        }
        return text =~ emojiRegex
    }

    func getIndexOfWordStart(index: Int, fromString str: String) -> String.Index {
        guard index > 0 else { return str.startIndex }
        for indexOffset in (0 ... index).reverse() {
            let cursorIndex = str.startIndex.advancedBy(indexOffset)
            let letter = str[cursorIndex]
            let prevLetter: Character?
            if indexOffset > 0 {
                prevLetter = str[cursorIndex.predecessor()]
            }
            else {
                prevLetter = nil
            }

            switch letter {
            case " ", "\n", "\r", "\t":
                if indexOffset == index {
                    return str.startIndex.advancedBy(indexOffset)
                }
                else {
                    return str.startIndex.advancedBy(indexOffset + 1)
                }
            case ":":
                if prevLetter == " " || prevLetter == ":" {
                    return str.startIndex.advancedBy(indexOffset)
                }
            default: break
            }
        }
        return str.startIndex
    }
}
