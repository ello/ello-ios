////
///  StreamableScreen.swift
//

import SnapKit


protocol StreamableScreenProtocol: class {
    var navigationBarTopConstraint: Constraint! { get }
    var navigationBar: ElloNavigationBar { get }
    func viewForStream() -> UIView
}

class StreamableScreen: NavBarScreen, StreamableScreenProtocol {
    let streamContainer = Container()

    convenience init() {
        self.init(frame: UIScreen.main.bounds)
    }

    override func arrange() {
        super.arrange(contentView: streamContainer)
        streamContainer.frame = self.bounds
    }

    func viewForStream() -> UIView {
        return streamContainer
    }

}
