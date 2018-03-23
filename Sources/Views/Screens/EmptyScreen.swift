////
///  EmptyScreen.swift
//

import SnapKit


class EmptyScreen: Screen {
    var blackBarIsVisible: Bool {
        get { return statusBar.isVisible }
        set {
            blackBarHeightConstraint.set(isActivated: !newValue)
            statusBar.isVisible = newValue
        }
    }
    let statusBar = StatusBar()
    private var blackBarHeightConstraint: Constraint!

    override func arrange() {
        addSubview(statusBar)

        statusBar.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(self)
            blackBarHeightConstraint = make.height.equalTo(0).priority(Priority.required).constraint
        }
        blackBarHeightConstraint.deactivate()
    }
}
