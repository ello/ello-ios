////
///  EditorialCellPresenter.swift
//

struct EditorialCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? EditorialCell,
            let editorial = streamCellItem.jsonable as? Editorial
        else { return }

        var config = EditorialCell.Config()
        config.title = editorial.title
        config.subtitle = editorial.subtitle
        config.invite = editorial.invite.map {
            EditorialCell.Config.Invite(emails: $0.emails, sent: $0.sent)
        }
        config.join = editorial.join.map {
            EditorialCell.Config.Join(email: $0.email, username: $0.username, password: $0.password)
        }

        if let postImageURL = editorial.post?.firstImageURL {
            config.imageURL = postImageURL
        }
        else if let asset = editorial.images[.size1x1],
            let imageURL = asset.largeOrBest?.url
        {
            config.imageURL = imageURL
        }

        cell.config = config
        (cell as? EditorialJoinCell)?.onJoinChange = { editorial.join = $0 }
        (cell as? EditorialInviteCell)?.onInviteChange = { editorial.invite = $0 }
    }
}
