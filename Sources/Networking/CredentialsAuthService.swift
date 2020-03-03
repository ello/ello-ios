////
///  CredentialsAuthService.swift
//

import Moya
import PromiseKit


class CredentialsAuthService {

    func authenticate(email: String, password: String) -> Promise<Void> {
        let endpoint: ElloAPI = .auth(email: email, password: password)
        let (promise, seal) = Promise<Void>.pending()
        ElloProvider.moya.request(endpoint) { (result) in
            switch result {
            case let .success(moyaResponse):
                switch moyaResponse.statusCode {
                case 200...299:
                    AuthenticationManager.shared.authenticated(isPasswordBased: true)
                    AuthToken.storeToken(
                        moyaResponse.data,
                        isPasswordBased: true,
                        email: email,
                        password: password
                    )
                    seal.fulfill(Void())
                default:
                    let elloError = ElloProvider.generateElloError(
                        moyaResponse.data,
                        statusCode: moyaResponse.statusCode
                    )
                    seal.reject(elloError)
                }
            case let .failure(error):
                seal.reject(error)
            }
        }
        return promise
    }

}
