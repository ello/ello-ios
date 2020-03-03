////
///  FakeCellSizeCalculator.swift
//

@testable import Ello


class FakeCellSizeCalculator: AnnouncementCellSizeCalculator {
    static func generator(height: CGFloat? = nil) -> StreamCellItem.CalculatorGenerator {
        return { streamCellItem, width, columnCount in
            let calculator = FakeCellSizeCalculator(
                item: streamCellItem,
                width: width,
                columnCount: columnCount
            )
            if let height = height {
                calculator.height = height
            }
            return calculator
        }
    }

    static func generatorWithStreamKind(height: CGFloat? = nil) -> StreamCellItem
        .CalculatorGeneratorWithStreamKind
    {
        return { _, streamCellItem, width, columnCount in
            let calculator = FakeCellSizeCalculator(
                item: streamCellItem,
                width: width,
                columnCount: columnCount
            )
            if let height = height {
                calculator.height = height
            }
            return calculator
        }
    }

    var height: CGFloat = ElloConfiguration.Size.calculatorHeight

    override func process() {
        assignCellHeight(all: height)
    }
}
