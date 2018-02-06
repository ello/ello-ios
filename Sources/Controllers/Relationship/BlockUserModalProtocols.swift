////
///  BlockUserModalProtocols.swift
//

protocol BlockUserModalScreenDelegate: class {
    func updateRelationship(_ newRelationship: RelationshipPriority)
    func flagTapped()
    func closeModal()
}

protocol BlockUserModalScreenProtocol: class {
}
