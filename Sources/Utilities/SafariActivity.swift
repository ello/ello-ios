////
///  SafariActivity.swift
//

class SafariActivity: UIActivity {
    var url: URL?

    override var activityType: UIActivity.ActivityType {
        return UIActivity.ActivityType("SafariActivity")
    }

    override var activityTitle: String {
        return InterfaceString.App.OpenInSafari
    }

    override var activityImage: UIImage? {
        return UIImage(named: "openInSafari")
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for item in activityItems {
            if let url = item as? URL, UIApplication.shared.canOpenURL(url) {
                return true
            }
        }
        return false
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        for item in activityItems {
            if let url = item as? URL {
                self.url = url
                break
            }
        }
    }

    override func perform() {
        guard let url = url else { return }

        UIApplication.shared.open(url, options: [:]) { completed in
            self.activityDidFinish(completed)
        }
    }

}
