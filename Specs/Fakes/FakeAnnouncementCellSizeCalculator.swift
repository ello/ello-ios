////
///  FakeAnnouncementCellSizeCalculator.swift
//

@testable import Ello
import Foundation


class FakeAnnouncementCellSizeCalculator: AnnouncementCellSizeCalculator {

    override func processCells(_ cellItems: [StreamCellItem], withWidth: CGFloat, completion: @escaping ElloEmptyCompletion) {
        for item in cellItems {
            item.calculatedCellHeights.oneColumn = AppSetup.Size.calculatorHeight
            item.calculatedCellHeights.multiColumn = AppSetup.Size.calculatorHeight
        }
        completion()
    }
}
