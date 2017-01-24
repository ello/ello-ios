////
///  LoadingToken.swift
//

import Foundation

struct LoadingToken {
    fileprivate var loadInitialPageLoadingToken: String = ""
    var cancelLoadingClosure: ElloEmptyCompletion = {}

    mutating func resetInitialPageLoadingToken() -> String {
        let newToken = UUID().uuidString
        loadInitialPageLoadingToken = newToken
        return newToken
    }

    func isValidInitialPageLoadingToken(_ token: String) -> Bool {
        return loadInitialPageLoadingToken == token
    }

    mutating func cancelInitialPage() {
        _ = resetInitialPageLoadingToken()
        self.cancelLoadingClosure()
    }
}
