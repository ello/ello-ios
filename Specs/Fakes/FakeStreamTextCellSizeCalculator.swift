////
///  FakeStreamTextCellSizeCalculator.swift
//

@testable import Ello


class FakeStreamTextCellSizeCalculator: StreamTextCellSizeCalculator {

    override func process() {
        assignCellHeight(one: ElloConfiguration.Size.calculatorHeight, multi: ElloConfiguration.Size.calculatorHeight)
    }
}
