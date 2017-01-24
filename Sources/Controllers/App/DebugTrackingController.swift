////
///  DebugTrackingController.swift
//


import SnapKit

class DebugTrackingController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let tableView = UITableView()
    var tracker: DebugAgent! { return Tracker.shared.overrideAgent as! DebugAgent }

    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Action")
        view.addSubview(tableView)

        tracker.logView.removeFromSuperview()

        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracker.log.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Tracking Events"
    }

    func tableView(_ tableView: UITableView, cellForRowAt path: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Action")
        if let label = cell.textLabel, let log = tracker.log.safeValue(path.row) {
            let header = NSAttributedString(log.1, font: UIFont.defaultBoldFont())
            let type = NSAttributedString(" \(log.0)", font: UIFont.defaultFont())
            label.attributedText = header + type
            cell.detailTextLabel?.text = log.2 ?? ""
        }
        return cell
    }

}

class DebugAgent: AnalyticsAgent {
    typealias Entry = (String, String, String?)
    var log: [Entry] = []
    let logView = UITextView()
    let logTextView = UITextView()
    var shouldHideStatusBar: Bool?

    static func format(_ entry: Entry) -> NSAttributedString {
        let retval = NSMutableAttributedString()
        retval.append(NSAttributedString("\(entry.0): ", color: .white))
        retval.append(NSAttributedString(entry.1, color: .white, font: UIFont.defaultBoldFont()))
        if let props = entry.2 {
            retval.append(NSAttributedString(" \(props)", color: .white))
        }
        return retval
    }

    init() {
        logTextView.backgroundColor = .black
        logTextView.isUserInteractionEnabled = false
        logView.addSubview(logTextView)
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(DebugAgent.viewTapped))
        logView.addGestureRecognizer(recognizer)
    }

    private func show() {
        if logView.superview == nil {
            UIWindow.mainWindow.addSubview(logView)
        }
        else {
            UIWindow.mainWindow.bringSubview(toFront: logView)
        }

        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            shouldHideStatusBar = rootViewController.prefersStatusBarHidden
        }
        else {
            shouldHideStatusBar = nil
        }

        postNotification(StatusBarNotifications.statusBarShouldHide, value: true)
        animate {
            self.logView.frame = UIWindow.mainWindow.bounds.fromTop().grow(down: ElloTabBar.Size.height)
            self.logTextView.frame.size = self.logView.frame.size
        }
    }

    private func dismiss() {
        animate {
            self.logView.frame.origin.y = -self.logView.frame.height
        }

        if let shouldHideStatusBar = shouldHideStatusBar {
            postNotification(StatusBarNotifications.statusBarShouldHide, value: shouldHideStatusBar)
        }
    }

    @objc
    func viewTapped() {
        dismiss()
    }

    private func describe(_ props: [AnyHashable: Any]) -> String {
        var retval = "{"
        var first = true
        for (key, value) in props {
            if !first {
                retval += "; "
            }
            retval += "\(key): \(value)"
            first = false
        }
        retval += "}"
        return retval
    }

    private func append(_ entry: Entry) {
        show()

        log.append(entry)
        let attributedText: NSAttributedString
        if let existing = logTextView.attributedText, !existing.string.isEmpty {
            attributedText = existing + NSAttributedString("\n")
        }
        else {
            attributedText = NSAttributedString()
        }
        logTextView.attributedText = attributedText + DebugAgent.format(entry)
        let contentOffsetY: CGFloat = logTextView.contentSize.height - logTextView.frame.size.height
        if contentOffsetY > 0 {
            logTextView.setContentOffset(CGPoint(x: 0, y: contentOffsetY), animated: true)
        }
    }

    func identify(_ userId: String!, traits: [AnyHashable: Any]!) {
        append(("User Id", userId, describe(traits)))
    }

    func track(_ event: String!) {
        append(("Event", event, nil))
    }

    func track(_ event: String!, properties: [AnyHashable: Any]!) {
        if let properties = properties {
            append(("Event", event, describe(properties)))
        }
        else {
            track(event)
        }
    }

    func screen(_ screenTitle: String!) {
        append(("Screen", screenTitle, nil))
    }

    func screen(_ screenTitle: String!, properties: [AnyHashable: Any]!) {
        if let properties = properties {
            append(("Screen", screenTitle, describe(properties)))
        }
        else {
            screen(screenTitle)
        }
    }
}
