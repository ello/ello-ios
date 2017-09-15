////
///  ElloWebView.swift
//

class ElloWebView: UIWebView {
    required override init(frame: CGRect) {
        super.init(frame: frame)
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
    }
}
