////
///  ArtistInviteDetailScreen.swift
//

class ArtistInviteDetailScreen: StreamableScreen, ArtistInviteDetailScreenProtocol {
    private let successScreen = ArtistInviteSubmissionSuccessScreen()

    override func setup() {
        successScreen.alpha = 0
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        if let window = window, successScreen.superview != window {
            window.addSubview(successScreen)

            successScreen.snp.makeConstraints { make in
                make.edges.equalTo(self)
            }
            successScreen.frame = window.bounds
        }
        else if window == nil, successScreen.superview != nil {
            successScreen.removeFromSuperview()
        }
    }

    func showSuccess() {
        elloAnimate {
            self.successScreen.alpha = 1
        }
        delay(3, block: hideSuccess)
    }

    func hideSuccess() {
        elloAnimate {
            self.successScreen.alpha = 0
        }
    }
}
