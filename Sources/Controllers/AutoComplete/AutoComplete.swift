////
///  AutoComplete.swift
//

struct AutoCompleteMatch: CustomStringConvertible, Equatable {

    var description: String {
        return "type: \(self.type), range: \(self.range), text: \(self.text)"
    }

    let type: AutoCompleteType
    let range: Range<String.Index>
    let text: String

    init(type: AutoCompleteType, range: Range<String.Index>, text: String ){
        self.type = type
        self.range = range
        self.text = text
    }
}

func == (lhs: AutoCompleteMatch, rhs: AutoCompleteMatch) -> Bool {
    return lhs.type == rhs.type && lhs.range == rhs.range && lhs.text == rhs.text
}

enum AutoCompleteType: String, CustomStringConvertible {
    case emoji = "Emoji"
    case username = "Username"
    case location = "Location"

    var description: String {
        return self.rawValue
    }
}

struct AutoComplete {

    init(){}

    func eagerCheck(_ text: String, location: Int) -> Bool {
        if location > text.characters.count { return false }
        let wordStartIndex = getIndexOfWordStart(location, fromString: text)
        let wordEndIndex = text.characters.index(text.startIndex, offsetBy: location)
        let charEndIndex: String.Index
        if wordStartIndex == text.characters.endIndex {
            charEndIndex = wordStartIndex
        }
        else {
            charEndIndex = text.characters.index(wordStartIndex, offsetBy: 1)
        }
        let char = text.substring(with: wordStartIndex..<charEndIndex)
        let substr = text.substring(with: wordStartIndex..<wordEndIndex)
        if (substr.characters.split { $0 == ":" }).count > 1 {
            return false
        }
        return char == "@" || char == ":"
    }

    func check(_ text: String, location: Int) -> AutoCompleteMatch? {
        if location > text.characters.count { return .none }

        let wordStartIndex = getIndexOfWordStart(location, fromString: text)
        let wordEndIndex = text.characters.index(text.startIndex, offsetBy: location)
        if wordStartIndex >= wordEndIndex { return .none }

        let range: Range<String.Index> = wordStartIndex..<wordEndIndex
        let word = text.substring(with: range)
        if findUsername(word) {
            return AutoCompleteMatch(type: .username, range: range, text: word)
        }
        else if findEmoji(word) {
            return AutoCompleteMatch(type: .emoji, range: range, text: word)
        }

        return .none
    }
}

private let usernameRegex = Regex("([^\\w]|\\s|^)@(\\w+)")!
private let emojiRegex = Regex("([^\\w]|\\s|^):(\\w+)")!

private extension AutoComplete {

    func findUsername(_ text: String) -> Bool {
        return text =~ usernameRegex
    }

    func findEmoji(_ text: String) -> Bool {
        // this handles ':one:two'
        if (text.characters.split { $0 == ":" }).count > 1 {
            return false
        }
        return text =~ emojiRegex
    }

    func getIndexOfWordStart(_ index: Int, fromString str: String) -> String.Index {
        guard index > 0 else { return str.startIndex }
        for indexOffset in (0 ..< index).reversed() {
            let cursorIndex = str.characters.index(str.startIndex, offsetBy: indexOffset)
            let letter = str[cursorIndex]
            let prevLetter: Character?
            if indexOffset > 0 {
                prevLetter = str[str.characters.index(before: cursorIndex)]
            }
            else {
                prevLetter = nil
            }

            switch letter {
            case " ", "\n", "\r", "\t":
                if indexOffset == index {
                    return str.characters.index(str.startIndex, offsetBy: indexOffset)
                }
                else {
                    return str.characters.index(str.startIndex, offsetBy: indexOffset + 1)
                }
            case ":":
                if prevLetter == " " || prevLetter == ":" {
                    return str.characters.index(str.startIndex, offsetBy: indexOffset)
                }
            default: break
            }
        }
        return str.startIndex
    }
}
