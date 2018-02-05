////
///  AnonymousAuthService.swift
//

import Moya

class AnonymousAuthService {

    func authenticateAnonymously(success: @escaping Block, failure: @escaping ElloFailureCompletion, noNetwork: Block) {
        let endpoint: ElloAPI = .anonymousCredentials
        ElloProvider.sharedProvider.request(endpoint) { (result) in
            switch result {
            case let .success(moyaResponse):
                switch moyaResponse.statusCode {
                case 200...299:
                    ElloProvider.shared.authenticated(isPasswordBased: false)
                    AuthToken.storeToken(moyaResponse.data, isPasswordBased: false)
                    success()
                default:
                    let elloError = ElloProvider.generateElloError(moyaResponse.data, statusCode: moyaResponse.statusCode)
                    failure(elloError)
                }
            case let .failure(error):
                failure(error)
            }
        }
    }

}
