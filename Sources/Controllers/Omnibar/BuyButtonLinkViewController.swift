////
///  BuyButtonLinkViewController.swift
//

class BuyButtonLinkViewController: UIViewController {
    private var _mockScreen: BuyButtonLinkScreenProtocol?
    var screen: BuyButtonLinkScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? self.view as! BuyButtonLinkScreen }
    }
    var buyButtonURL: URL?
    weak var delegate: BuyButtonLinkControllerDelegate?

    required init(buyButtonURL: URL?) {
        self.buyButtonURL = buyButtonURL
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let screen = BuyButtonLinkScreen()
        screen.buyButtonURL = buyButtonURL
        screen.delegate = self
        view = screen
    }

}

extension BuyButtonLinkViewController: BuyButtonLinkScreenDelegate {

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
