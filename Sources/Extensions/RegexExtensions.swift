//
//  RegexExtensions.swift
//  Ello
//
//  Created by Colin Gray on 9/17/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//
import Foundation

class Regex {
    let regex: NSRegularExpression!
    let pattern: String

    init?(_ pattern: String) {
        self.pattern = pattern
        var error: NSError?
        do {
            self.regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue: 0))
        } catch let error1 as NSError {
            error = error1
            self.regex = nil
        }
        if error != nil { return nil }
    }

    func test(_ input: String) -> Bool {
        return match(input) != nil
    }

    func match(_ input: String) -> String? {
        if let range = input.range(of: pattern, options: .regularExpression) {
            return input.substring(with: range)
        }
        return nil
    }

    func matches(_ input: String) -> [String] {
        let nsstring = input as NSString
        let matches = self.regex.matches(in: input, options: [], range: NSRange(location: 0, length: nsstring.length))
        var ret = [String]()
        for match in matches {
            let range = match.rangeAt(0)
            ret.append(nsstring.substring(with: range))
        }
        return ret
    }

    func matchingGroups(_ input: String) -> [String] {
        let nsstring = input as NSString
        var ret = [String]()
        if let match = self.regex.firstMatch(in: input, options: [], range: NSRange(location: 0, length: nsstring.length)) {

            for i in 0..<match.numberOfRanges {
                let range = match.rangeAt(i)
                if range.location != NSNotFound {
                    let matchedString = nsstring.substring(with: range)
                    ret.append(matchedString)
                }
            }
        }
        return ret
    }

}

infix operator =~ : ComparisonPrecedence
infix operator !~ : ComparisonPrecedence
infix operator ~ : LogicalConjunctionPrecedence

func =~ (input: String, pattern: String) -> Bool {
    if let regex = Regex(pattern) {
        return input =~ regex
    }
    return false
}

func =~ (input: String, regex: Regex) -> Bool {
    return regex.test(input)
}

func !~ (input: String, pattern: String) -> Bool {
    if let regex = Regex(pattern) {
        return input !~ regex
    }
    return false
}

func !~ (input: String, regex: Regex) -> Bool {
    return !regex.test(input)
}

func ~ (input: String, pattern: String) -> String? {
    if let regex = Regex(pattern) {
        return input ~ regex
    }
    return nil
}

func ~ (input: String, regex: Regex) -> String? {
    return regex.match(input)
}
