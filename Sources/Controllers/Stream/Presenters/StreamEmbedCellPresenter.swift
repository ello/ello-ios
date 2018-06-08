////
///  StreamEmbedCellPresenter.swift
//

struct StreamEmbedCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard let cell = cell as? StreamEmbedCell,
            let embedData = streamCellItem.type.data as? EmbedRegion
        else { return }

        cell.embedUrl = embedData.url
        if embedData.isAudioEmbed {
            cell.setPlayImageIcon(.audioPlay)
        }
        else {
            cell.setPlayImageIcon(.videoPlay)
        }

        if let photoURL = embedData.thumbnailLargeUrl {
            cell.setImageURL(photoURL)
        }

        // Repost specifics
        if embedData.isRepost {
            cell.leadingConstraint.constant = 30.0
            cell.showBorder()
        }
        else {
            cell.leadingConstraint.constant = 0.0
        }
    }
}
