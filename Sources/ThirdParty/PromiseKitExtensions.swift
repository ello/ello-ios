////
///  PromiseKitExtensions.swift
//

import PromiseKit


extension Promise {

    func thenFinally(execute body: @escaping (T) throws -> Void) -> Promise<Void> {
        return then(execute: body)
    }

    @discardableResult
    func ignoreErrors() -> Promise<T> {
        return self
    }
}
