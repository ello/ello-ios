////
///  BuyButtonLinkProtocols.swift
//

protocol BuyButtonLinkControllerDelegate: class {
    func submitBuyButtonLink(_ url: URL)
    func clearBuyButtonLink()
}

protocol BuyButtonLinkScreenProtocol: class {
    var buyButtonURL: URL? { get set }
    var delegate: BuyButtonLinkScreenDelegate? { get set }
}

protocol BuyButtonLinkScreenDelegate: class {
    func closeModal()
    func submitLink(_ url: URL)
    func clearLink()
}
