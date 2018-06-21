////
///  CategoryCardCellPresenter.swift
//

struct CategoryCardCellPresenter {

    static func configure(
        _ cell: UICollectionViewCell,
        streamCellItem: StreamCellItem,
        streamKind: StreamKind,
        indexPath: IndexPath,
        currentUser: User?)
    {
        guard
            let cell = cell as? CategoryCardCell,
            let category = streamCellItem.jsonable as? Category
        else { return }

        cell.title = category.name
        cell.imageURL = category.tileURL

        switch streamCellItem.type {
        case .categorySubscribeCard:
            cell.usage = .subscribing
        case let .categoryChooseCard(isSubscribed, isSelected):
            cell.usage = .choosing
            cell.isSubscribed = isSubscribed
            cell.isSelected = isSelected
        case .onboardingCategoryCard:
            cell.usage = .onboarding
        default:
            break
        }
    }

}
