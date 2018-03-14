////
///  ChooseCategoryScreen.swift
//

class ChooseCategoryScreen: StreamableScreen, ChooseCategoryScreenProtocol {
    weak var delegate: ChooseCategoryScreenDelegate?

    override func style() {
        navigationBar.leftItems = [.back]
    }

}
