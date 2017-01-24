////
///  DrawerPopControl.swift
//

class DrawerPopControl: UIControl {
    var presentingController: UIViewController?

    init() {
        super.init(frame: .zero)
        addTarget(self, action: #selector(DrawerPopControl.pop), for: .touchDown)
    }

    func pop() {
        presentingController?.dismiss(animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
