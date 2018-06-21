////
///  NavBarScreen.swift
//

import SnapKit


class NavBarScreen: Screen {
    let navigationBar = ElloNavigationBar()
    var navigationBarTopConstraint: Constraint!

    func arrange(contentView: UIView?) {
        contentView.map { addSubview($0) }
        addSubview(navigationBar)

        navigationBar.snp.makeConstraints { make in
            navigationBarTopConstraint = make.top.equalTo(self).constraint
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
        }

        contentView?.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }

    func showNavBars(animated: Bool) {
        elloAnimate(animated: animated) {
            self.navigationBarTopConstraint.update(offset: 0)
            if animated {
                self.layoutIfNeeded()
            }
        }
    }

    func hideNavBars(animated: Bool) {
        elloAnimate(animated: animated) {
            self.navigationBarTopConstraint.update(offset: -self.navigationBar.frame.height)
            if animated {
                self.layoutIfNeeded()
            }
        }
    }
}
