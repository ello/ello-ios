////
///  BlockUserModalViewController.swift
//

import Foundation
import SnapKit


class BlockUserModalViewController: BaseElloViewController, BlockUserModalDelegate {
    weak var relationshipDelegate: RelationshipDelegate?

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

        relationshipDelegate?.updateRelationship(currentUserId, userId: userId, prev: relationshipPriority, relationshipPriority: newRelationship) {
            (status, relationship, isFinalValue) in
            switch status {
            case .success:
                self.changeClosure(newRelationship)
                self.closeModal()
            case .failure:
                self.changeClosure(self.relationshipPriority)
            }
        }
    }

    func flagTapped() {
        if let presentingViewController = presentingViewController {
            let flagger = ContentFlagger(
                presentingController: presentingViewController,
                flaggableId: userId,
                contentType: .user
            )

            closeModalAndThen {
                flagger.displayFlaggingSheet()
            }
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
