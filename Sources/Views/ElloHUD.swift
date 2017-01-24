////
///  ElloHUD.swift
//

import MBProgressHUD

class ElloHUD {

    @discardableResult
    class func showLoadingHudInView(_ view: UIView) -> MBProgressHUD? {
        var existingHub: MBProgressHUD?
        for subview in view.subviews {
            if let found = subview as? MBProgressHUD {
                existingHub = found
                break
            }
        }
        if let existingHub = existingHub {
            return existingHub
        }

        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.opacity = 0.0

        let elloLogo = ElloLogoView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        elloLogo.animateLogo()
        hud?.customView = elloLogo
        hud?.mode = .customView
        hud?.removeFromSuperViewOnHide = true
        return hud
    }

    class func hideLoadingHudInView(_ view: UIView) {
        MBProgressHUD.hide(for: view, animated: true)
    }

}
