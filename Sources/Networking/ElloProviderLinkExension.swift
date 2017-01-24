////
///  ElloProviderLinkExension.swift
//

import Foundation
import WebLinking

extension ElloProvider {
    func parseLinks(_ response: HTTPURLResponse?, config: ResponseConfig) -> ResponseConfig {
        if let nextLink = response?.findLink(relation: "next") {
            if let comps = URLComponents(string: nextLink.uri) {
                config.nextQueryItems = comps.queryItems as [AnyObject]?
            }
        }
        if let prevLink = response?.findLink(relation: "prev") {
            if let comps = URLComponents(string: prevLink.uri) {
                config.prevQueryItems = comps.queryItems as [AnyObject]?
            }
        }
        if let firstLink = response?.findLink(relation: "first") {
            if let comps = URLComponents(string: firstLink.uri) {
                config.firstQueryItems = comps.queryItems as [AnyObject]?
            }
        }
        if let lastLink = response?.findLink(relation: "last") {
            if let comps = URLComponents(string: lastLink.uri) {
                config.lastQueryItems = comps.queryItems as [AnyObject]?
            }
        }
        return config
    }
}
