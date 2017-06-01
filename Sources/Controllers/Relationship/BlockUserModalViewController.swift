////
///  BlockUserModalViewController.swift
//

import SnapKit


class BlockUserModalViewController: BaseElloViewController, BlockUserModalDelegate {

    let config: BlockUserModalConfig
    var relationshipPriority: RelationshipPriority { return config.relationshipPriority }
    var userId: String { return config.userId }
    var userAtName: String { return config.userAtName }
    var changeClosure: RelationshipChangeClosure { return config.changeClosure }

    var screen: BlockUserModalScreen { return self.view as! BlockUserModalScreen }

    required init(config: BlockUserModalConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let screen = BlockUserModalScreen(config: config)
        self.view = screen
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let superView = self.view.superview {
            self.view.center = superView.center
        }
    }

    func updateRelationship(_ newRelationship: RelationshipPriority) {
        guard let currentUserId = currentUser?.id else {
            closeModal()
            return
        }

        switch newRelationship {
            case .block: Tracker.shared.userBlocked(userId)
            case .mute: Tracker.shared.userMuted(userId)
            case .inactive:
                if relationshipPriority == .block {
                    Tracker.shared.userUnblocked(userId)
                }
                else if relationshipPriority == .mute {
                    Tracker.shared.userUnmuted(userId)
                }
            default: break
        }

        let responder: RelationshipResponder? = findResponder()
        responder?.updateRelationship(
            currentUserId,
            userId: userId,
            prev: RelationshipPriorityWrapper(priority: relationshipPriority),
            relationshipPriority: RelationshipPriorityWrapper(priority: newRelationship))
        { [weak self] statusWrapper, relationship, isFinalValue in
            guard let `self` = self else { return }
            switch statusWrapper.status {
            case .success:
                self.changeClosure(RelationshipPriorityWrapper(priority: newRelationship))
                self.closeModal()
            case .failure:
                self.changeClosure(RelationshipPriorityWrapper(priority: self.relationshipPriority))
            }
        }
    }

    func flagTapped() {
        guard
            let presentingViewController = presentingViewController
        else { return }

        let flagger = ContentFlagger(
            presentingController: presentingViewController,
            flaggableId: userId,
            contentType: .user
        )

        closeModalAndThen {
            flagger.displayFlaggingSheet()
        }
    }

    func closeModal() {
        closeModalAndThen {}
    }

    func closeModalAndThen(_ completion: @escaping BasicBlock) {
        Tracker.shared.userBlockCanceled(userId)
        self.dismiss(animated: true, completion: completion)
    }

}
