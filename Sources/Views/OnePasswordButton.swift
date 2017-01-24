////
///  OnePasswordButton.swift
//

class OnePasswordButton: UIButton {

    required override init(frame: CGRect) {
        super.init(frame: frame)
        sharedSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedSetup()
    }

    func sharedSetup() {
        setImage(.onePassword, imageStyle: .white, for: .normal)
        contentMode = .center
    }

}
