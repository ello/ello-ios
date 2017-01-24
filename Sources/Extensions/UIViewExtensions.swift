////
///  UIViewExtensions.swift
//

extension UIView {

    func findParentView<T>(_ test: ((T) -> Bool)? = nil) -> T? where T: UIView {
        var view: UIView? = superview
        while view != nil {
            if let view = view as? T, test?(view) ?? true {
                return view
            }
            view = view?.superview
        }
        return nil
    }
}
