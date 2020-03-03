////
///  UIViewExtensions.swift
//

extension UIView {
    var isVisible: Bool {
        get { return !isHidden }
        set { isHidden = !newValue }
    }

    var firstResponder: UIView? {
        return findSubview { $0.isFirstResponder }
    }

    func findAllSubviews<T>(_ test: ((T) -> Bool)? = nil) -> [T] {
        var views: [T] = []
        if let view = self as? T, test?(view) ?? true {
            views.append(view)
        }

        for subview in subviews {
            let subviews: [T] = subview.findAllSubviews(test)
            views += subviews
        }

        return views
    }

    func findSubview<T>(_ test: ((T) -> Bool)? = nil) -> T? {
        if let view = self as? T, test?(view) ?? true {
            return view
        }

        for subview in subviews {
            guard let subview:T = subview.findSubview(test) else { continue }
            return subview
        }

        return nil
    }

    func findParentView<T>(_ test: ((T) -> Bool)? = nil) -> T? {
        var view: UIView? = superview
        while view != nil {
            if let view = view as? T, test?(view) ?? true {
                return view
            }
            view = view?.superview
        }
        return nil
    }

    func convertFrame(of view: UIView) -> CGRect {
        let rect = CGRect.zero.with(size: view.frame.size)
        return convert(rect, from: view)
    }
}
