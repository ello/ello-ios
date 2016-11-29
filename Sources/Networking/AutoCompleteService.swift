////
///  AutoCompleteService.swift
//

import Alamofire
import SwiftyJSON

public typealias AutoCompleteServiceSuccessCompletion = (results: [AutoCompleteResult], responseConfig: ResponseConfig) -> ()

public struct AutoCompleteService {

    public init(){}

    public func loadUsernameResults(
        terms: String,
        success: AutoCompleteServiceSuccessCompletion,
        failure: ElloFailureCompletion)
    {
        ElloProvider.shared.elloRequest(
            .UserNameAutoComplete(terms: terms),
            success: { (data, responseConfig) in
                if let results = data as? [AutoCompleteResult] {
                    success(results: results, responseConfig: responseConfig)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }

    public func loadEmojiResults(text: String) -> [AutoCompleteResult] {
        let emojiName: String
        if text[text.startIndex] == ":" {
            emojiName = text.substringFromIndex(text.startIndex.advancedBy(1))
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
    static func loadEmojiJSON(defaultJSON: String) {
        let data = stubbedData(defaultJSON)
        let json: JSON
        do {
            json = try JSON(data: data)
        }
        catch {
            json = JSON("")
        }

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

        Alamofire.request(.GET, "\(ElloURI.baseURL)/emojis.json")
            .responseJSON { response in
                if let JSON = response.result.value,
                    emojis = JSON["emojis"] as? [[String: String]]
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

    public func loadLocationResults(
        search: String,
        success: AutoCompleteServiceSuccessCompletion,
        failure: ElloFailureCompletion)
    {
        ElloProvider.shared.elloRequest(
            .LocationAutoComplete(search: search),
            success: { (data, responseConfig) in
                if let results = data as? [AutoCompleteResult] {
                    success(results: results, responseConfig: responseConfig)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }

}
