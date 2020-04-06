////
///  UserService.swift
//

import Moya
import SwiftyJSON
import PromiseKit


struct UserService {

    func join(
        email: String,
        username: String,
        password: String,
        invitationCode: String? = nil
    ) -> Promise<User> {
        return ElloProvider.shared.request(
            .join(
                email: email,
                username: username,
                password: password,
                invitationCode: invitationCode
            )
        )
            .then { data, _ -> Promise<User> in
                guard let user = data as? User else {
                    throw NSError.uncastableModel()
                }

                let promise: Promise<User> = CredentialsAuthService().authenticate(
                    email: email,
                    password: password
                )
                    .map { _ -> User in
                        return user
                    }
                return promise
            }
    }

    func requestPasswordReset(email: String) -> Promise<()> {
        return ElloProvider.shared.request(.requestPasswordReset(email: email))
            .asVoid()
    }

    func resetPassword(password: String, authToken: String) -> Promise<User> {
        return ElloProvider.shared.request(.resetPassword(password: password, authToken: authToken))
            .map { user, _ -> User in
                guard let user = user as? User else {
                    throw NSError.uncastableModel()
                }
                return user
            }
    }

    func loadUser(_ endpoint: ElloAPI) -> Promise<User> {
        return ElloProvider.shared.request(endpoint)
            .map { data, responseConfig -> User in
                guard let user = data as? User else {
                    throw NSError.uncastableModel()
                }
                Preloader().preloadImages([user])
                return user
            }
    }

    func loadUserPosts(_ userId: String) -> Promise<([Post], ResponseConfig)> {
        return ElloProvider.shared.request(.userStreamPosts(userId: userId))
            .map { data, responseConfig -> ([Post], ResponseConfig) in
                let posts: [Post]?
                if data as? String == "" {
                    posts = []
                }
                else if let foundPosts = data as? [Post] {
                    posts = foundPosts
                }
                else {
                    posts = nil
                }

                if let posts = posts {
                    Preloader().preloadImages(posts)
                    return (posts, responseConfig)
                }
                else {
                    throw NSError.uncastableModel()
                }
            }
    }
}
