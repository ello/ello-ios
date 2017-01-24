////
///  OmnibarScreenBuyButtonLinkControllerDelegate.swift
//

extension OmnibarScreen: BuyButtonLinkControllerDelegate {

    func submitBuyButtonLink(_ url: URL) {
        buyButtonURL = url
        regionsTableView.reloadData()
    }

    func clearBuyButtonLink() {
        buyButtonURL = nil
        regionsTableView.reloadData()
    }

}
