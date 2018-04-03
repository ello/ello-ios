////
///  StreamGenerator.swift
//

protocol StreamGenerator {
    var currentUser: User? { get }
    var streamKind: StreamKind { get }
    var destination: StreamDestination? { get }
}

extension StreamGenerator {

    func parse(jsonables: [JSONAble], forceGrid: Bool = false) -> [StreamCellItem] {
        return StreamCellItemParser().parse(jsonables, streamKind: streamKind, forceGrid: forceGrid, currentUser: self.currentUser)
    }
}

protocol StreamDestination: class {
    func setPlaceholders(items: [StreamCellItem])
    func replacePlaceholder(type: StreamCellType.PlaceholderType, items: [StreamCellItem], completion: @escaping Block)
    func setPrimary(jsonable: JSONAble)
    func primaryJSONAbleNotFound()
    func setPagingConfig(responseConfig: ResponseConfig)
    var isPagingEnabled: Bool { get set }
}

extension StreamDestination {
    func replacePlaceholder(type: StreamCellType.PlaceholderType, items: [StreamCellItem]) {
        replacePlaceholder(type: type, items: items, completion: {})
    }
}
