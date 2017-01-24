////
///  UIWebView.swift
//

extension UIWebView {

    func windowContentSize() -> CGSize? {
        if let jsWidth = self.stringByEvaluatingJavaScript(from: "(document.getElementById('post-container') || document.getElementByTagName('div')[0] || document.body).offsetWidth"), !jsWidth.isEmpty
        {
            if let jsHeight = self.stringByEvaluatingJavaScript(from: "(document.getElementById('post-container') || document.getElementByTagName('div')[0] || document.body).offsetHeight + 15"), !jsHeight.isEmpty
            {
                let width = CGFloat((jsWidth as NSString).doubleValue)
                let height = CGFloat((jsHeight as NSString).doubleValue)
                return CGSize(width: width, height: height)
            }
        }
        return nil
    }
}
