////
///  AnonymousAuthService.swift
//

import Moya

public class AnonymousAuthService {

    public func authenticateAnonymously(success success: AuthSuccessCompletion, failure: ElloFailureCompletion, noNetwork: ElloEmptyCompletion) {
        let endpoint: ElloAPI = .AnonymousCredentials
        ElloProvider.sharedProvider.request(endpoint) { (result) in
            switch result {
            case let .Success(moyaResponse):
                switch moyaResponse.statusCode {
                case 200...299:
                    ElloProvider.shared.authenticated(isPasswordBased: false)
                    AuthToken.storeToken(moyaResponse.data, isPasswordBased: false)
                    success()
                default:
                    let elloError = ElloProvider.generateElloError(moyaResponse.data, statusCode: moyaResponse.statusCode)
                    failure(error: elloError, statusCode: moyaResponse.statusCode)
                }
            case let .Failure(error):
                failure(error: error as NSError, statusCode: nil)
            }
        }
    }

}
