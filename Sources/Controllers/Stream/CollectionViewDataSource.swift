////
///  CollectionViewDataSource.swift
//

class CollectionViewDataSource: ElloDataSource, UICollectionViewDataSource {
    private var inviteCache = InviteCache()

    func isFullWidth(at indexPath: IndexPath) -> Bool {
        guard let item = streamCellItem(at: indexPath) else { return true }

        if item.type.isFullWidth {
            return true
        }
        return !item.isGridView(streamKind: streamKind)
    }

    func isTappable(at indexPath: IndexPath) -> Bool {
        guard let item = streamCellItem(at: indexPath) else { return false }

        if item.type.isSelectable {
            return true
        }
        return !isFullWidth(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCellItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard isValidIndexPath(indexPath) else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: StreamCellType.unknown.reuseIdentifier, for: indexPath)
        }

        let streamCellItem = visibleCellItems[indexPath.item]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: streamCellItem.type.reuseIdentifier, for: indexPath)

        switch streamCellItem.type {
        case .inviteFriends, .onboardingInviteFriends:
            (cell as! StreamInviteFriendsCell).inviteCache = inviteCache
        default:
            break
        }

        streamCellItem.type.configure(
            cell,
            streamCellItem,
            streamKind,
            indexPath,
            currentUser
        )

        return cell
    }

    func height(at indexPath: IndexPath, numberOfColumns: NSInteger) -> CGFloat {
        guard let item = streamCellItem(at: indexPath) else { return 0 }

        // always try to return a calculated value before the default
        if numberOfColumns == 1 {
            if let height = item.calculatedCellHeights.oneColumn {
                return height
            }
            else {
                return item.type.oneColumnHeight
            }
        }
        else {
            if let height = item.calculatedCellHeights.multiColumn {
                return height
            }
            else {
                return item.type.multiColumnHeight
            }
        }
    }

    func group(at indexPath: IndexPath) -> String? {
        guard
            let item = streamCellItem(at: indexPath),
            let groupId = item.groupId
        else { return nil }

        return groupId
    }

}
