////
///  NotificationsProtocols.swift
//

protocol NotificationsScreenDelegate: class {
    func activatedCategory(_ filter: String)
}

protocol NotificationsScreenProtocol: class {
    var delegate: NotificationsScreenDelegate? { get set }
    var navBarVisible: Bool { get set }
    var filterBar: NotificationsFilterBar { get }
    var streamContainer: UIView { get }

    func selectFilterButton(_ filter: NotificationFilterType)
}
