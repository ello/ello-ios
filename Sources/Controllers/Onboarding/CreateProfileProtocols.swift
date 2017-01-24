////
///  CreateProfileProtocols.swift
//

protocol CreateProfileDelegate: class {
    func present(controller: UIViewController)
    func dismissController()

    func assign(name: String?) -> ValidationState
    func assign(bio: String?) -> ValidationState
    func assign(links: String?) -> ValidationState
    func assign(coverImage: ImageRegionData)
    func assign(avatarImage: ImageRegionData)
}

protocol CreateProfileScreenProtocol: class {
    var name: String? { get set }
    var bio: String? { get set }
    var links: String? { get set }
    var linksValid: Bool? { get set }
    var coverImage: ImageRegionData? { get set }
    var avatarImage: ImageRegionData? { get set }
}
