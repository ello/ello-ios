////
///  StringExtensions.swift
//

import Keys


// static variables, to store HTML entities
private var entityLookup: [String : String] = populateEntityLookup()

private var srcRegex: NSRegularExpression? = try? NSRegularExpression(
                pattern: "src=[\"']([^\"']*)[\"']",
                options: .caseInsensitive)


extension String {

    func rangeFromNSRange(_ nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
        else { return nil }
        return from ..< to
    }

    // finds image tags, replaces them with data:image/png (inlines image data)
    func stripHtmlImgSrc() -> String {
        guard let srcRegex = srcRegex else {
            return self
        }
        let range = NSRange(location: 0, length: count)
        return srcRegex.stringByReplacingMatches(in: self,
            options: .reportCompletion,
            range: range,
            withTemplate: "src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAAAAAA6fptVAAAACklEQVR4nGNiAAAABgADNjd8qAAAAABJRU5ErkJggg==\"")
    }

    func urlEncoded() -> String {
        return addingPercentEncoding(withAllowedCharacters: CharacterSet.letters) ?? self
    }

    func urlDecoded() -> String {
        return removingPercentEncoding ?? ""
    }

    func entitiesEncoded() -> String {
        let scalarLookup: [(String, String)] = [
            ("&", "&amp;"),
            ("\"", "&quot;"),
            ("'", "&#039;"),
            ("<", "&lt;"),
            (">", "&gt;"),
        ]

        var entitiesEncoded = self
        for replacement in scalarLookup {
            entitiesEncoded = entitiesEncoded.replacingOccurrences(of: replacement.0, with: replacement.1)
        }

        return entitiesEncoded
    }

    func entitiesDecoded() -> String {
        let scanner = Scanner(string: self)
        scanner.charactersToBeSkipped = nil
        var entitiesDecoded = ""

        while !scanner.isAtEnd {
            var scanned: NSString?

            if scanner.scanUpTo("&", into:&scanned) {
                entitiesDecoded += scanned! as String
            }

            if scanner.scanString("&", into: nil) {
                var afterAmpersandPtr: NSString?
                if scanner.scanUpTo(";", into: &afterAmpersandPtr) {
                    let afterAmpersand = afterAmpersandPtr! as String

                    if scanner.scanString(";", into: nil)  {
                        if afterAmpersand.hasPrefix("#") && afterAmpersand.count <= 6 {
                            let ch = Int(afterAmpersand[secondIndex...])
                            if let ch = ch {
                                entitiesDecoded += String(format: "%C", ch)
                            }
                            else {
                                entitiesDecoded += "&"
                                entitiesDecoded += afterAmpersand
                                entitiesDecoded += ";"
                            }
                        }
                        else  {
                            let converted = entityLookup[afterAmpersand]

                            if let converted = converted {
                                entitiesDecoded += converted
                            }
                            else  {
                                // not a valid sequence
                                entitiesDecoded += "&"
                                entitiesDecoded += afterAmpersand
                                entitiesDecoded += ";"
                            }
                        }

                    }
                    else  {
                        // no semicolon
                        entitiesDecoded += "&"
                        entitiesDecoded += afterAmpersand
                    }
                }
            }
        }

        return entitiesDecoded
    }

    func split(_ splitChars: Character...) -> [String] {
        return split(whereSeparator: { (c: Character) -> Bool in
            return splitChars.any { s in
                return s == c
            }
        }).map { String($0) }
    }

    func trimmed() -> String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    var camelCase: String {
        let splits = split("_")
        var capSplits: [String] = splits.map { s in
            return String(s[startIndex]).capitalized + String(s[secondIndex...])
        }
        capSplits.replaceSubrange(0..<1, with: [splits.first ?? ""])
        return capSplits.joined(separator: "")
    }

    var first: String? {
        guard !isEmpty else { return nil }
        return String(self[startIndex])
    }

    var secondIndex: String.Index { return index(after: startIndex) }
    var secondToLastIndex: String.Index { return index(before: endIndex) }

    var last: String? {
        guard !isEmpty else { return nil }
        return String(self[index(before: endIndex)])
    }

    var uppercaseFirst: String {
        guard let first = first else { return "" }
        return first.uppercased() + String(self[secondIndex...])
    }
}

extension Optional where Wrapped == String {
    var isEmpty: Bool {
        return self?.isEmpty ?? true
    }
}


private func populateEntityLookup() -> [String: String] {
    // swiftlint:disable colon
    return [
        "quot"     : "\"",
        "amp"      : "&",
        "apos"     : "'",
        "lt"       : "<",
        "gt"       : ">",
        "nbsp"     : "\u{00a0}",
        "iexcl"    : "\u{00a1}",
        "cent"     : "\u{00a2}",
        "pound"    : "\u{00a3}",
        "curren"   : "\u{00a4}",
        "yen"      : "\u{00a5}",
        "brvbar"   : "\u{00a6}",
        "sect"     : "\u{00a7}",
        "uml"      : "\u{00a8}",
        "copy"     : "\u{00a9}",
        "ordf"     : "\u{00aa}",
        "laquo"    : "\u{00ab}",
        "not"      : "\u{00ac}",
        "reg"      : "\u{00ae}",
        "macr"     : "\u{00af}",
        "deg"      : "\u{00b0}",
        "plusmn"   : "\u{00b1}",
        "sup2"     : "\u{00b2}",
        "sup3"     : "\u{00b3}",
        "acute"    : "\u{00b4}",
        "micro"    : "\u{00b5}",
        "para"     : "\u{00b6}",
        "middot"   : "\u{00b7}",
        "cedil"    : "\u{00b8}",
        "sup1"     : "\u{00b9}",
        "ordm"     : "\u{00ba}",
        "raquo"    : "\u{00bb}",
        "frac14"   : "\u{00bc}",
        "frac12"   : "\u{00bd}",
        "frac34"   : "\u{00be}",
        "iquest"   : "\u{00bf}",
        "Agrave"   : "\u{00c0}",
        "Aacute"   : "\u{00c1}",
        "Acirc"    : "\u{00c2}",
        "Atilde"   : "\u{00c3}",
        "Auml"     : "\u{00c4}",
        "Aring"    : "\u{00c5}",
        "AElig"    : "\u{00c6}",
        "Ccedil"   : "\u{00c7}",
        "Egrave"   : "\u{00c8}",
        "Eacute"   : "\u{00c9}",
        "Ecirc"    : "\u{00ca}",
        "Euml"     : "\u{00cb}",
        "Igrave"   : "\u{00cc}",
        "Iacute"   : "\u{00cd}",
        "Icirc"    : "\u{00ce}",
        "Iuml"     : "\u{00cf}",
        "ETH"      : "\u{00d0}",
        "Ntilde"   : "\u{00d1}",
        "Ograve"   : "\u{00d2}",
        "Oacute"   : "\u{00d3}",
        "Ocirc"    : "\u{00d4}",
        "Otilde"   : "\u{00d5}",
        "Ouml"     : "\u{00d6}",
        "times"    : "\u{00d7}",
        "Oslash"   : "\u{00d8}",
        "Ugrave"   : "\u{00d9}",
        "Uacute"   : "\u{00da}",
        "Ucirc"    : "\u{00db}",
        "Uuml"     : "\u{00dc}",
        "Yacute"   : "\u{00dd}",
        "THORN"    : "\u{00de}",
        "szlig"    : "\u{00df}",
        "agrave"   : "\u{00e0}",
        "aacute"   : "\u{00e1}",
        "acirc"    : "\u{00e2}",
        "atilde"   : "\u{00e3}",
        "auml"     : "\u{00e4}",
        "aring"    : "\u{00e5}",
        "aelig"    : "\u{00e6}",
        "ccedil"   : "\u{00e7}",
        "egrave"   : "\u{00e8}",
        "eacute"   : "\u{00e9}",
        "ecirc"    : "\u{00ea}",
        "euml"     : "\u{00eb}",
        "igrave"   : "\u{00ec}",
        "iacute"   : "\u{00ed}",
        "icirc"    : "\u{00ee}",
        "iuml"     : "\u{00ef}",
        "eth"      : "\u{00f0}",
        "ntilde"   : "\u{00f1}",
        "ograve"   : "\u{00f2}",
        "oacute"   : "\u{00f3}",
        "ocirc"    : "\u{00f4}",
        "otilde"   : "\u{00f5}",
        "ouml"     : "\u{00f6}",
        "divide"   : "\u{00f7}",
        "oslash"   : "\u{00f8}",
        "ugrave"   : "\u{00f9}",
        "uacute"   : "\u{00fa}",
        "ucirc"    : "\u{00fb}",
        "uuml"     : "\u{00fc}",
        "yacute"   : "\u{00fd}",
        "thorn"    : "\u{00fe}",
        "yuml"     : "\u{00ff}",
        "OElig"    : "\u{0152}",
        "oelig"    : "\u{0153}",
        "Scaron"   : "\u{0160}",
        "scaron"   : "\u{0161}",
        "Yuml"     : "\u{0178}",
        "fnof"     : "\u{0192}",
        "circ"     : "\u{02c6}",
        "tilde"    : "\u{02dc}",
        "Gamma"    : "\u{0393}",
        "Delta"    : "\u{0394}",
        "Theta"    : "\u{0398}",
        "Lambda"   : "\u{039b}",
        "Xi"       : "\u{039e}",
        "Sigma"    : "\u{03a3}",
        "Upsilon"  : "\u{03a5}",
        "Phi"      : "\u{03a6}",
        "Psi"      : "\u{03a8}",
        "Omega"    : "\u{03a9}",
        "alpha"    : "\u{03b1}",
        "Alpha"    : "\u{0391}",
        "beta"     : "\u{03b2}",
        "Beta"     : "\u{0392}",
        "gamma"    : "\u{03b3}",
        "delta"    : "\u{03b4}",
        "epsilon"  : "\u{03b5}",
        "Epsilon"  : "\u{0395}",
        "zeta"     : "\u{03b6}",
        "Zeta"     : "\u{0396}",
        "eta"      : "\u{03b7}",
        "Eta"      : "\u{0397}",
        "theta"    : "\u{03b8}",
        "iota"     : "\u{03b9}",
        "Iota"     : "\u{0399}",
        "kappa"    : "\u{03ba}",
        "Kappa"    : "\u{039a}",
        "lambda"   : "\u{03bb}",
        "mu"       : "\u{03bc}",
        "Mu"       : "\u{039c}",
        "nu"       : "\u{03bd}",
        "Nu"       : "\u{039d}",
        "xi"       : "\u{03be}",
        "omicron"  : "\u{03bf}",
        "Omicron"  : "\u{039f}",
        "pi"       : "\u{03c0}",
        "Pi"       : "\u{03a0}",
        "rho"      : "\u{03c1}",
        "Rho"      : "\u{03a1}",
        "sigmaf"   : "\u{03c2}",
        "sigma"    : "\u{03c3}",
        "tau"      : "\u{03c4}",
        "Tau"      : "\u{03a4}",
        "upsilon"  : "\u{03c5}",
        "phi"      : "\u{03c6}",
        "chi"      : "\u{03c7}",
        "Chi"      : "\u{03a7}",
        "psi"      : "\u{03c8}",
        "omega"    : "\u{03c9}",
        "thetasym" : "\u{03d1}",
        "upsih"    : "\u{03d2}",
        "piv"      : "\u{03d6}",
        "ensp"     : "\u{2002}",
        "emsp"     : "\u{2003}",
        "thinsp"   : "\u{2009}",
        "ndash"    : "\u{2013}",
        "mdash"    : "\u{2014}",
        "lsquo"    : "\u{2018}",
        "rsquo"    : "\u{2019}",
        "sbquo"    : "\u{201a}",
        "bsquo"    : "\u{201a}",
        "ldquo"    : "\u{201c}",
        "rdquo"    : "\u{201d}",
        "bdquo"    : "\u{201e}",
        "dagger"   : "\u{2020}",
        "Dagger"   : "\u{2021}",
        "bull"     : "\u{2022}",
        "hellip"   : "\u{2026}",
        "permil"   : "\u{2030}",
        "prime"    : "\u{2032}",
        "Prime"    : "\u{2033}",
        "lsaquo"   : "\u{2039}",
        "rsaquo"   : "\u{203a}",
        "oline"    : "\u{203e}",
        "frasl"    : "\u{2044}",
        "euro"     : "\u{20ac}",
        "image"    : "\u{2111}",
        "weierp"   : "\u{2118}",
        "real"     : "\u{211c}",
        "trade"    : "\u{2122}",
        "alefsym"  : "\u{2135}",
        "larr"     : "\u{2190}",
        "uarr"     : "\u{2191}",
        "rarr"     : "\u{2192}",
        "darr"     : "\u{2193}",
        "harr"     : "\u{2194}",
        "crarr"    : "\u{21b5}",
        "lArr"     : "\u{21d0}",
        "uArr"     : "\u{21d1}",
        "rArr"     : "\u{21d2}",
        "dArr"     : "\u{21d3}",
        "hArr"     : "\u{21d4}",
        "forall"   : "\u{2200}",
        "part"     : "\u{2202}",
        "exist"    : "\u{2203}",
        "empty"    : "\u{2205}",
        "nabla"    : "\u{2207}",
        "isin"     : "\u{2208}",
        "notin"    : "\u{2209}",
        "ni"       : "\u{220b}",
        "prod"     : "\u{220f}",
        "sum"      : "\u{2211}",
        "minus"    : "\u{2212}",
        "lowast"   : "\u{2217}",
        "radic"    : "\u{221a}",
        "prop"     : "\u{221d}",
        "infin"    : "\u{221e}",
        "ang"      : "\u{2220}",
        "and"      : "\u{2227}",
        "or"       : "\u{2228}",
        "cap"      : "\u{2229}",
        "cup"      : "\u{222a}",
        "int"      : "\u{222b}",
        "there4"   : "\u{2234}",
        "sim"      : "\u{223c}",
        "cong"     : "\u{2245}",
        "asymp"    : "\u{2248}",
        "ne"       : "\u{2260}",
        "equiv"    : "\u{2261}",
        "le"       : "\u{2264}",
        "ge"       : "\u{2265}",
        "sub"      : "\u{2282}",
        "sup"      : "\u{2283}",
        "nsub"     : "\u{2284}",
        "sube"     : "\u{2286}",
        "supe"     : "\u{2287}",
        "oplus"    : "\u{2295}",
        "otimes"   : "\u{2297}",
        "perp"     : "\u{22a5}",
        "sdot"     : "\u{22c5}",
        "lceil"    : "\u{2308}",
        "rceil"    : "\u{2309}",
        "lfloor"   : "\u{230a}",
        "rfloor"   : "\u{230b}",
        "lang"     : "\u{27e8}",
        "rang"     : "\u{27e9}",
        "loz"      : "\u{25ca}",
        "spades"   : "\u{2660}",
        "clubs"    : "\u{2663}",
        "hearts"   : "\u{2665}",
        "diams"    : "\u{2666}",
    ]
    // swiftlint:enable colon
}
