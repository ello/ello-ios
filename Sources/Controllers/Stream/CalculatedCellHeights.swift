////
///  CalculatedCellHeights.swift
//


typealias OnCalculatedCellHeightsMismatch = (CalculatedCellHeights) -> Void

struct CalculatedCellHeights {
    var oneColumn: CGFloat?
    var multiColumn: CGFloat?
    var webContent: CGFloat?
}
