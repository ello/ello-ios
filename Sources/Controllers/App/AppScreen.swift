////
///  AppScreen.swift
//

import SnapKit


class AppScreen: EmptyScreen {
    fileprivate var logoImage = ElloLogoView()

    override func arrange() {
        super.arrange()
        addSubview(logoImage)

        logoImage.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self)
        }
    }
}

extension AppScreen: AppScreenProtocol {
    func animateLogo() {
        logoImage.animateLogo()
    }

    func stopAnimatingLogo() {
        logoImage.stopAnimatingLogo()
    }

    func hide() {
        logoImage.alpha = 0
    }
}
