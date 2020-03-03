////
///  CellSizeCalculator.swift
//

class CellSizeCalculator: NSObject {
    var cellItem: StreamCellItem
    var width: CGFloat
    var columnCount: Int
    private var completion: Block!

    init(item: StreamCellItem, width: CGFloat, columnCount: Int) {
        self.cellItem = item
        self.width = width
        self.columnCount = columnCount
        super.init()
    }

    func begin(completion: @escaping Block) {
        self.completion = completion
        process()
    }

    func finish() {
        completion()
    }

    func process() {
        fatalError("subclass \(type(of: self)) should implement process()")
    }

    func assignCellHeight(all columnHeight: CGFloat) {
        cellItem.calculatedCellHeights.oneColumn = columnHeight
        cellItem.calculatedCellHeights.multiColumn = columnHeight
        finish()
    }

    func assignCellHeight(
        one oneColumnHeight: CGFloat,
        multi multiColumnHeight: CGFloat,
        web webColumnHeight: CGFloat? = nil
    ) {
        cellItem.calculatedCellHeights.oneColumn = oneColumnHeight
        cellItem.calculatedCellHeights.multiColumn = multiColumnHeight
        cellItem.calculatedCellHeights.webContent = webColumnHeight
        finish()
    }
}
