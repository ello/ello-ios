////
///  RegexExtensions.swift
//

class Regex {
    let regex: NSRegularExpression!
    let pattern: String

    init?(_ pattern: String) {
        self.pattern = pattern
        var error: NSError?
        do {
            self.regex = try NSRegularExpression(
                pattern: pattern,
                options: NSRegularExpression.Options(rawValue: 0)
            )
        }
        catch let error1 as NSError {
            error = error1
            self.regex = nil
        }
        if error != nil { return nil }
    }

    func test(_ input: String) -> Bool {
        return match(input) != nil
    }

    func match(_ input: String) -> String? {
        guard let range = input.range(of: pattern, options: .regularExpression) else { return nil }
        return String(input[range])
    }

    func matches(_ input: String) -> [String] {
        let matches = self.regex.matches(
            in: input,
            options: [],
            range: NSRange(location: 0, length: input.count)
        )
        var ret = [String]()
        for match in matches {
            let nsrange = match.range(at: 0)
            guard let range = input.rangeFromNSRange(nsrange) else { continue }
            ret.append(String(input[range]))
        }
        return ret
    }

    func matchingGroups(_ input: String) -> [String] {
        var ret = [String]()
        if let match = self.regex.firstMatch(
            in: input,
            options: [],
            range: NSRange(location: 0, length: input.count)
        ) {

            for i in 0..<match.numberOfRanges {
                let nsrange = match.range(at: i)
                if nsrange.location != NSNotFound {
                    guard let range = input.rangeFromNSRange(nsrange) else { continue }
                    ret.append(String(input[range]))
                }
            }
        }
        return ret
    }

}

infix operator =~: ComparisonPrecedence
infix operator !~: ComparisonPrecedence
infix operator ~: LogicalConjunctionPrecedence

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
