////
///  ElloHUDWindowExtensions.swift
//

extension ElloHUD {

    class func showLoadingHud() {
        if let win = UIApplication.shared.windows.last {
            ElloHUD.showLoadingHudInView(win)
        }
    }

    class func hideLoadingHud() {
        if let win = UIApplication.shared.windows.last {
            ElloHUD.hideLoadingHudInView(win)
        }
    }
}
