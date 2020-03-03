////
///  ArtistInvitesProtocols.swift
//

protocol ArtistInvitesScreenDelegate: class {
    func scrollToTop()
}

protocol ArtistInviteDetailScreenProtocol: StreamableScreenProtocol {
    func showSuccess()
}
protocol ArtistInviteAdminScreenProtocol: StreamableScreenProtocol {
    var selectedSubmissionsStatus: ArtistInviteSubmission.Status { get set }
}

protocol ArtistInviteAdminScreenDelegate: class {
    func tappedApprovedSubmissions()
    func tappedSelectedSubmissions()
    func tappedUnapprovedSubmissions()
    func tappedDeclinedSubmissions()
}

protocol ArtistInviteConfigurableCell: class {
    var config: ArtistInviteBubbleCell.Config { get set }
}

protocol ArtistInviteResponder: class {
    func tappedArtistInviteSubmissionsButton()
    func tappedArtistInviteSubmitButton()
}

protocol ArtistInviteAdminResponder: class {
    func tappedArtistInviteAction(
        cell: ArtistInviteAdminControlsCell,
        action: ArtistInviteSubmission.Action
    )
}
