////
///  ArtistInviteService.swift
//

import PromiseKit


class ArtistInviteService {

    func load(id: String) -> Promise<ArtistInvite> {
        return ElloProvider.shared.request(.artistInviteDetail(id: id))
            .map { data, _ -> ArtistInvite in
                if let artistInvite = data as? ArtistInvite {
                    return artistInvite
                }
                else {
                    throw NSError.uncastableModel()
                }
            }
    }

    func performAction(action: ArtistInviteSubmission.Action) -> Promise<ArtistInviteSubmission> {
        return ElloProvider.shared.request(action.endpoint)
            .map { data, _ -> ArtistInviteSubmission in
                if let submission = data as? ArtistInviteSubmission {
                    return submission
                }
                else {
                    throw NSError.uncastableModel()
                }
            }
    }

}
