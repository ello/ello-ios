////
///  ChooseCategoryProtocols.swift
//

protocol ChooseCategoryScreenDelegate: class {
}

protocol ChooseCategoryScreenProtocol: StreamableScreenProtocol {
}

protocol ChooseCategoryControllerDelegate: class {
    func categoryChosen(_ category: Category)
}
