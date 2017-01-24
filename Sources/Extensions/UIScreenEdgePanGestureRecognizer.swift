////
///  UIScreenEdgePanGestureRecognizer.swift
//

extension UIScreenEdgePanGestureRecognizer {
    func percentageThroughView(_ backEdge: UIRectEdge) -> CGFloat {
        let view = self.view!
        let x = location(in: view).x
        let width = view.bounds.size.width
        let percent = x / width

        if (translation(in: view).x > 0.0) && (backEdge == UIRectEdge.left) {
            return percent
        }

        if (translation(in: view).x < 0.0) && (backEdge == UIRectEdge.right) {
            return 1.0 - percent
        }

        return 0.0
    }
}
