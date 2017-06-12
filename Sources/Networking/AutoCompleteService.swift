////
///  AutoCompleteService.swift
//

import Alamofire
import SwiftyJSON
import PromiseKit


struct AutoCompleteService {

    func loadUsernameResults(_ terms: String) -> Promise<[AutoCompleteResult]> {
        return ElloProvider.shared.request(.userNameAutoComplete(terms: terms))
            .then { response -> [AutoCompleteResult] in
                guard let results = response.0 as? [AutoCompleteResult] else {
                    throw NSError.uncastableJSONAble()
                }
                return results
            }
    }

    func loadEmojiResults(_ text: String) -> [AutoCompleteResult] {
        let emojiName: String
        if text[text.startIndex] == ":" {
            emojiName = text.substring(from: text.characters.index(text.startIndex, offsetBy: 1))
        }
        else {
            emojiName = text
        }
        return AutoCompleteService.emojis.filter {
            ":\($0.name):".contains(emojiName)
        }.map {
            AutoCompleteResult(name: $0.name, url: $0.url)
        }
    }

    static var emojis: [(name: String, url: String)] = []
    static func loadEmojiJSON(_ defaultJSON: String) {
        let data = stubbedData(defaultJSON)
        let json = JSON(data: data)

        if let emojis = json["emojis"].object as? [[String: String]]
        {
            self.emojis = emojis.map {
                var name = ""
                var imageUrl = ""
                if let emojiName = $0["name"] {
                    name = emojiName
                }
                if let emojiUrl = $0["image_url"] {
                    imageUrl = emojiUrl
                }
                return (name: name, url: imageUrl)
            }
        }

        Alamofire.request("\(ElloURI.baseURL)/emojis.json")
            .responseJSON { response in
                if let JSON = response.result.value as? [String: Any],
                    let emojis = JSON["emojis"] as? [[String: String]]
                {
                    self.emojis = emojis.map {
                        var name = ""
                        var imageUrl = ""
                        if let emojiName = $0["name"] {
                            name = emojiName
                        }
                        if let emojiUrl = $0["image_url"] {
                            imageUrl = emojiUrl
                        }
                        return (name: name, url: imageUrl)
                    }
                }
            }
    }

    func loadLocationResults(_ terms: String) -> Promise<[AutoCompleteResult]> {
        return ElloProvider.shared.request(.locationAutoComplete(terms: terms))
            .then { response -> [AutoCompleteResult] in
                guard let results = response.0 as? [AutoCompleteResult] else {
                    throw NSError.uncastableJSONAble()
                }
                return results
            }
    }

}
