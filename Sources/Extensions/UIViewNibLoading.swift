////
///  UIViewNibLoading.swift
//

extension UIView {
    public class func loadFromNib<T: UIView>(viewType: T.Type) -> T {
        return
            Bundle.main.loadNibNamed(viewType.readableClassName(), owner: nil, options: nil)!.first
            as! T
    }

    public class func loadFromNib() -> Self {
        return loadFromNib(viewType: self)
    }

}
