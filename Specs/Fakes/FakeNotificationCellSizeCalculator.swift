////
///  FakeNotificationCellSizeCalculator.swift
//

@testable
import Ello


class FakeNotificationCellSizeCalculator: NotificationCellSizeCalculator {

    override func process() {
        assignCellHeight(one: ElloConfiguration.Size.calculatorHeight, multi: ElloConfiguration.Size.calculatorHeight)
    }
}
