////
///  ElloHUDWindowExtensions.swift
//

import MBProgressHUD

extension ElloHUD {

    class func showLoadingHud() -> MBProgressHUD? {
        if let win = UIApplication.shared.windows.last {
            return ElloHUD.showLoadingHudInView(win)
        }
        else {
            return nil
        }
    }

    class func hideLoadingHud() {
        if let win = UIApplication.shared.windows.last {
            ElloHUD.hideLoadingHudInView(win)
        }
    }
}
