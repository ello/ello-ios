////
///  DebugViewsController.swift
//


class DebugViewsController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let relationships: [RelationshipPriority] = [
            .none,
            .following,
            .starred,
            .mute,
        ]
        let controls: [RelationshipControl] = relationships.map { priority in
            let control = RelationshipControl()
            control.translatesAutoresizingMaskIntoConstraints = false
            control.relationshipPriority = priority
            self.view.addSubview(control)
            self.view.backgroundColor = .white

            return control
        }
        var prevControl: RelationshipControl? = nil

        if #available(iOS 9.0, *) {
            for control in controls {
                control.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true

                if let prevControl = prevControl {
                    control.topAnchor.constraint(equalTo: prevControl.bottomAnchor, constant: 8).isActive = true
                }
                else {
                    control.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
                }

                prevControl = control
            }
        }
    }

}
