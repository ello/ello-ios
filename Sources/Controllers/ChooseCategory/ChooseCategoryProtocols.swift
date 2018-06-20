////
///  ChooseCategoryProtocols.swift
//

protocol ChooseCategoryScreenDelegate: class {
}

protocol ChooseCategoryScreenProtocol: StreamableScreenProtocol {
}

@objc
protocol ChooseCategoryControllerDelegate: class {
    @objc optional func chooseCategoryShouldGoBack() -> Bool
    func categoryChosen(_ category: Category)
}
