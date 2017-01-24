////
///  AutoCompleteService.swift
//

import Alamofire
import SwiftyJSON

typealias AutoCompleteServiceSuccessCompletion = (_ results: [AutoCompleteResult], _ responseConfig: ResponseConfig) -> ()

struct AutoCompleteService {

    init(){}

    func loadUsernameResults(
        _ terms: String,
        success: @escaping AutoCompleteServiceSuccessCompletion,
        failure: @escaping ElloFailureCompletion)
    {
        ElloProvider.shared.elloRequest(
            .userNameAutoComplete(terms: terms),
            success: { (data, responseConfig) in
                if let results = data as? [AutoCompleteResult] {
                    success(results, responseConfig)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
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

    func loadLocationResults(
        _ terms: String,
        success: @escaping AutoCompleteServiceSuccessCompletion,
        failure: @escaping ElloFailureCompletion)
    {
        ElloProvider.shared.elloRequest(
            .locationAutoComplete(terms: terms),
            success: { (data, responseConfig) in
                if let results = data as? [AutoCompleteResult] {
                    success(results, responseConfig)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }

}
