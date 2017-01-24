////
///  FakeStreamTextCellSizeCalculator.swift
//

@testable import Ello


class FakeStreamTextCellSizeCalculator: StreamTextCellSizeCalculator {

    override func processCells(_ cellItems: [StreamCellItem], withWidth: CGFloat, columnCount: Int, completion: @escaping ElloEmptyCompletion) {
        for item in cellItems {
            item.calculatedCellHeights.oneColumn = AppSetup.Size.calculatorHeight
            item.calculatedCellHeights.multiColumn = AppSetup.Size.calculatorHeight
        }
        completion()
    }
}
