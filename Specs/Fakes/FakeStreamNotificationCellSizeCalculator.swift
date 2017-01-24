////
///  FakeStreamNotificationCellSizeCalculator.swift
//

@testable import Ello
import Foundation


class FakeStreamNotificationCellSizeCalculator: StreamNotificationCellSizeCalculator {

    override func processCells(_ cellItems: [StreamCellItem], withWidth: CGFloat, completion: @escaping ElloEmptyCompletion) {
        for item in cellItems {
            item.calculatedCellHeights.oneColumn = AppSetup.Size.calculatorHeight
            item.calculatedCellHeights.multiColumn = AppSetup.Size.calculatorHeight
        }
        completion()
    }
}
