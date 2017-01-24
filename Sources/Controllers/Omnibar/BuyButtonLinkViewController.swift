////
///  BuyButtonLinkViewController.swift
//

protocol BuyButtonLinkControllerDelegate: class {
    func submitBuyButtonLink(_ url: URL)
    func clearBuyButtonLink()
}

class BuyButtonLinkViewController: UIViewController {
    var screen: BuyButtonLinkScreen { return self.view as! BuyButtonLinkScreen }
    var buyButtonURL: URL?
    weak var delegate: BuyButtonLinkControllerDelegate?

    required init(buyButtonURL: URL?) {
        self.buyButtonURL = buyButtonURL
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let screen = BuyButtonLinkScreen()
        screen.buyButtonURL = buyButtonURL
        screen.delegate = self
        view = screen
    }

}

extension BuyButtonLinkViewController: BuyButtonLinkDelegate {

    func closeModal() {
        dismiss(animated: true, completion: nil)
    }

    func submitLink(_ url: URL) {
        delegate?.submitBuyButtonLink(url)
    }

    func clearLink() {
        delegate?.clearBuyButtonLink()
    }

}
