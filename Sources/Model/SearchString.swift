////
///  SearchString.swift
//

let SearchStringVersion: Int = 1

@objc(SearchString)
final class SearchString: Model {
    var text: String

    init(text: String) {
        self.text = text
        super.init(version: SearchStringVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.text = decoder.decodeKey("text")
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(text, forKey: "text")
        super.encode(with: coder)
    }

    class func fromJSON(_ data: [String: Any]) -> SearchString {
        return SearchString(text: (data["text"] as? String) ?? "")
    }

}
