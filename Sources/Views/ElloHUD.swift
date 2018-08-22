////
///  ElloHUD.swift
//

class ElloHUD: View {
    var showCount = 0
    let elloLogo = GradientLoadingView()

    override func arrange() {
        addSubview(elloLogo)

        elloLogo.snp.makeConstraints { make in
            make.center.equalTo(self)
        }
    }

    class func showLoadingHudInView(_ view: UIView) {
        if let existingHud: ElloHUD = view.findSubview() {
            existingHud.showCount += 1
            return
        }

        let hud = ElloHUD()
        view.addSubview(hud)

        hud.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }

        hud.elloLogo.startAnimating()
    }

    class func hideLoadingHudInView(_ view: UIView) {
        guard let hud: ElloHUD = view.findSubview() else { return }
        guard hud.showCount == 0 else {
            hud.showCount -= 1
            return
        }

        elloAnimate {
            hud.alpha = 0
        }.done {
            hud.removeFromSuperview()
        }
    }

}
