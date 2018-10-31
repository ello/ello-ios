////
///  BadgesService.swift
//

import Alamofire
import SwiftyJSON


class BadgesService {
    static func loadStaticBadges() {
        guard !Globals.isTesting else { return }

        Alamofire.request("\(ElloURI.baseURL)/api/v2/badges.json")
            .responseJSON { response in
                guard
                    let jsonObject = response.result.value as? [String: Any],
                    let badgesJson = jsonObject["badges"] as? [[String: Any]]
                else { return }

                var badges: [String: Badge] = [:]
                for json in badgesJson {
                    guard let slug = json["slug"] as? String else { continue }
                    badges[slug] = Badge.fromJSON(json as [String: Any])
                }

                Badge.badges = badges
            }
    }
}
