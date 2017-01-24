////
///  DeleteAccountConfirmationViewController.swift
//

private enum DeleteAccountState {
    case askNicely
    case areYouSure
    case noTurningBack
}

class DeleteAccountConfirmationViewController: BaseElloViewController {
    @IBOutlet weak var titleLabel: UILabel!
    weak var infoLabel: StyledLabel!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var cancelView: UIView!
    weak var cancelLabel: StyledLabel!

    fileprivate var state: DeleteAccountState = .askNicely
    fileprivate var timer: Timer?
    fileprivate var counter = 5

    init() {
        super.init(nibName: "DeleteAccountConfirmationView", bundle: Bundle(for: DeleteAccountConfirmationViewController.self))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        infoLabel.text = "* \(InterfaceString.Settings.DeleteAccountExplanation)"
        cancelLabel.textAlignment = .center
        cancelLabel.textColor = .white

        updateInterface()
    }

    fileprivate func updateInterface() {
        switch state {
        case .askNicely:
            let title = InterfaceString.Settings.DeleteAccountConfirm
            titleLabel.text = title

        case .areYouSure:
            let title = InterfaceString.AreYouSure
            titleLabel.text = title
            infoLabel.isHidden = false

        case .noTurningBack:
            let title = InterfaceString.Settings.AccountIsBeingDeleted
            titleLabel.text = title
            titleLabel.font = UIFont(descriptor: titleLabel.font.fontDescriptor, size: 18)
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(DeleteAccountConfirmationViewController.tick), userInfo: .none, repeats: true)
            infoLabel.isHidden = true
            buttonView.isHidden = true
            cancelView.isHidden = false
        }
    }

    @objc
    fileprivate func tick() {
        let text = NSString(format: InterfaceString.Settings.RedirectedCountdownTemplate as NSString, counter) as String
        nextTick {
            self.cancelLabel.text = text
            self.counter -= 1
            if self.counter <= 0 {
                self.deleteAccount()
            }
        }
    }

    fileprivate func deleteAccount() {
        timer?.invalidate()
        _ = ElloHUD.showLoadingHud()

        ProfileService().deleteAccount(success: {
            ElloHUD.hideLoadingHud()
            self.dismiss(animated: true) {
                postNotification(AuthenticationNotifications.userLoggedOut, value: ())
            }
            Tracker.shared.userDeletedAccount()
        }, failure: { _, _ in
            ElloHUD.hideLoadingHud()
        })
    }

    @IBAction func yesButtonTapped() {
        switch state {
        case .askNicely: state = .areYouSure
        case .areYouSure: state = .noTurningBack
        default: break
        }
        updateInterface()
    }

    @IBAction fileprivate func dismiss() {
        timer?.invalidate()
        self.dismiss(animated: true, completion: .none)
    }
}
