////
///  ArtistInvite.swift
//

import SwiftyJSON


@objc(ArtistInvite)
final class ArtistInvite: Model {
    // Version 1: initial
    static let Version = 1

    struct Guide {
        let title: String
        let html: String
    }

    struct Stream {
        let endpoint: ElloAPI
        let label: String
        let submissionsStatus: ArtistInviteSubmission.Status

        init?(link: [String: Any], submissionsStatus: ArtistInviteSubmission.Status) {
            guard
                let url = (link["href"] as? String).flatMap({ URL(string: $0) }),
                let label = link["label"] as? String
            else { return nil }

            self.endpoint = .custom(url: url, mimics: .artistInviteSubmissions)
            self.label = label
            self.submissionsStatus = submissionsStatus
        }
    }

    enum Status: String {
        case preview
        case upcoming
        case open
        case selecting
        case closed
    }

    let id: String
    let slug: String
    let title: String
    let shortDescription: String
    let submissionBody: String
    let longDescription: String
    let inviteType: String
    let status: Status
    let openedAt: Date?
    let closedAt: Date?
    var headerImage: Asset?
    var logoImage: Asset?
    var guide: [Guide] = []
    var approvedSubmissionsStream: Stream?
    var selectedSubmissionsStream: Stream?
    var unapprovedSubmissionsStream: Stream?
    var declinedSubmissionsStream: Stream?
    override var description: String { return longDescription }

    var shareLink: String {
        return "\(ElloURI.baseURL)/invites/\(slug)"
    }
    var hasAdminLinks: Bool {
        return approvedSubmissionsStream != nil && unapprovedSubmissionsStream != nil
    }

    init(
        id: String,
        slug: String,
        title: String,
        shortDescription: String,
        submissionBody: String,
        longDescription: String,
        inviteType: String,
        status: Status,
        openedAt: Date?,
        closedAt: Date?)
    {
        self.id = id
        self.slug = slug
        self.title = title
        self.shortDescription = shortDescription
        self.submissionBody = submissionBody
        self.longDescription = longDescription
        self.inviteType = inviteType
        self.status = status
        self.openedAt = openedAt
        self.closedAt = closedAt
        super.init(version: ArtistInvite.Version)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        id = decoder.decodeKey("id")
        slug = decoder.decodeKey("slug")
        title = decoder.decodeKey("title")
        shortDescription = decoder.decodeKey("shortDescription")
        submissionBody = decoder.decodeKey("submissionBody")
        longDescription = decoder.decodeKey("longDescription")
        inviteType = decoder.decodeKey("inviteType")
        status = Status(rawValue: decoder.decodeKey("status")) ?? .closed
        openedAt = decoder.decodeOptionalKey("openedAt")
        closedAt = decoder.decodeOptionalKey("closedAt")
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(slug, forKey: "slug")
        encoder.encodeObject(title, forKey: "title")
        encoder.encodeObject(shortDescription, forKey: "shortDescription")
        encoder.encodeObject(submissionBody, forKey: "submissionBody")
        encoder.encodeObject(longDescription, forKey: "longDescription")
        encoder.encodeObject(inviteType, forKey: "inviteType")
        encoder.encodeObject(status.rawValue, forKey: "status")
        encoder.encodeObject(openedAt, forKey: "openedAt")
        encoder.encodeObject(closedAt, forKey: "closedAt")
        super.encode(with: coder)
    }

    class func fromJSON(_ data: [String: Any]) -> ArtistInvite {
        let json = JSON(data)

        let id = json["id"].stringValue
        let slug = json["slug"].stringValue
        let title = json["title"].stringValue
        let shortDescription = json["short_description"].stringValue
        let longDescription = json["description"].stringValue
        let inviteType = json["invite_type"].stringValue
        let status = Status(rawValue: json["status"].stringValue) ?? .closed
        let submissionBody = json["submission_body_block"].stringValue
        let openedAt = json["opened_at"].string?.toDate()
        let closedAt = json["closed_at"].string?.toDate()

        let artistInvite = ArtistInvite(
            id: id,
            slug: slug,
            title: title,
            shortDescription: shortDescription,
            submissionBody: submissionBody,
            longDescription: longDescription,
            inviteType: inviteType,
            status: status,
            openedAt: openedAt,
            closedAt: closedAt)

        artistInvite.headerImage = Asset.parseAsset("artist_invite_header_\(id)", node: data["header_image"] as? [String: Any])
        artistInvite.logoImage = Asset.parseAsset("artist_invite_logo_\(id)", node: data["logo_image"] as? [String: Any])

        if let approvedSubmissionsLink = json["links"]["approved_submissions"].object as? [String: Any],
            let stream = Stream(link: approvedSubmissionsLink, submissionsStatus: .approved)
        {
            artistInvite.approvedSubmissionsStream = stream
        }

        if let selectedSubmissionsLink = json["links"]["selected_submissions"].object as? [String: Any],
            let stream = Stream(link: selectedSubmissionsLink, submissionsStatus: .selected)
        {
            artistInvite.selectedSubmissionsStream = stream
        }

        if let unapprovedSubmissionsLink = json["links"]["unapproved_submissions"].object as? [String: Any],
            let stream = Stream(link: unapprovedSubmissionsLink, submissionsStatus: .unapproved)
        {
            artistInvite.unapprovedSubmissionsStream = stream
        }

        if let declinedSubmissionsLink = json["links"]["declined_submissions"].object as? [String: Any],
            let stream = Stream(link: declinedSubmissionsLink, submissionsStatus: .declined)
        {
            artistInvite.declinedSubmissionsStream = stream
        }

        if let guide = json["guide"].array?.compactMap({ $0.object as? [String: String] }) {
            artistInvite.guide = guide.compactMap { g -> Guide? in
                guard let title = g["title"], let html = g["rendered_body"] else { return nil }
                return Guide(title: title, html: html)
            }
        }

        artistInvite.mergeLinks(data["links"] as? [String: Any])
        return artistInvite
    }
}

extension ArtistInvite: JSONSaveable {
    var uniqueId: String? { return "ArtistInvite-\(id)" }
    var tableId: String? { return id }
}
