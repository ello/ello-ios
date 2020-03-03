////
///  ReAuthService.swift
//

import Moya


class ReAuthService {

    func reAuthenticateToken(
        success: @escaping Block,
        failure: @escaping ErrorBlock,
        noNetwork: @escaping Block
    ) {
        let endpoint: ElloAPI
        let token = AuthToken()
        let refreshToken = token.refreshToken
        if let refreshToken = refreshToken, token.isPasswordBased {
            endpoint = .reAuth(token: refreshToken)
        }
        else {
            endpoint = .anonymousCredentials
        }

        ElloProvider.moya.request(endpoint) { (result) in
            switch result {
            case let .success(moyaResponse):
                let statusCode = moyaResponse.statusCode
                let data = moyaResponse.data

                switch statusCode {
                case 200...299:
                    AuthToken.storeToken(data, isPasswordBased: true)
                    success()
                default:
                    let elloError = ElloProvider.generateElloError(data, statusCode: statusCode)
                    failure(elloError)
                }
            case .failure:
                noNetwork()
            }
        }
    }

    func reAuthenticateUserCreds(
        success: @escaping Block,
        failure: @escaping ErrorBlock,
        noNetwork: @escaping Block
    ) {
        var token = AuthToken()
        if let email = token.username, let password = token.password {
            let endpoint: ElloAPI = .auth(email: email, password: password)
            ElloProvider.moya.request(endpoint) { (result) in
                switch result {
                case let .success(moyaResponse):
                    let statusCode = moyaResponse.statusCode
                    let data = moyaResponse.data

                    switch statusCode {
                    case 200...299:
                        AuthToken.storeToken(data, isPasswordBased: true)
                        success()
                    default:
                        let elloError = ElloProvider.generateElloError(data, statusCode: statusCode)
                        failure(elloError)
                    }
                case .failure:
                    noNetwork()
                }
            }
        }
        else {
            let elloError = NSError.networkError("Failed to send request", code: .networkFailure)
            failure(elloError)
        }
    }

}
