////
///  AnonymousAuthService.swift
//

import Moya

class AnonymousAuthService {

    func authenticateAnonymously(
        success: @escaping Block,
        failure: @escaping ErrorBlock,
        noNetwork: Block
    ) {
        let endpoint: ElloAPI = .anonymousCredentials
        ElloProvider.moya.request(endpoint) { (result) in
            switch result {
            case let .success(moyaResponse):
                switch moyaResponse.statusCode {
                case 200...299:
                    AuthenticationManager.shared.authenticated(isPasswordBased: false)
                    AuthToken.storeToken(moyaResponse.data, isPasswordBased: false)
                    success()
                default:
                    let elloError = ElloProvider.generateElloError(
                        moyaResponse.data,
                        statusCode: moyaResponse.statusCode
                    )
                    failure(elloError)
                }
            case let .failure(error):
                failure(error)
            }
        }
    }

}
