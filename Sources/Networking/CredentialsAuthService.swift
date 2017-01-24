////
///  CredentialsAuthService.swift
//

import Moya

typealias AuthSuccessCompletion = () -> Void

class CredentialsAuthService {

    func authenticate(email: String, password: String, success: @escaping AuthSuccessCompletion, failure: @escaping ElloFailureCompletion) {
        let endpoint: ElloAPI = .auth(email: email, password: password)
        ElloProvider.sharedProvider.request(endpoint) { (result) in
            switch result {
            case let .success(moyaResponse):
                switch moyaResponse.statusCode {
                case 200...299:
                    ElloProvider.shared.authenticated(isPasswordBased: true)
                    AuthToken.storeToken(moyaResponse.data, isPasswordBased: true, email: email, password: password)
                    success()
                default:
                    let elloError = ElloProvider.generateElloError(moyaResponse.data, statusCode: moyaResponse.statusCode)
                    failure(elloError, moyaResponse.statusCode)
                }
            case let .failure(error):
                failure(error as NSError, nil)
            }
        }
    }

}
