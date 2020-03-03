////
///  CategoryPresentAnimation.swift
//

class CategoryAnimation: NSObject {
    typealias ViewFrame = (view: UIView, frame: CGRect)
    let categoryViewInfo: ViewFrame?
    let categoryCellInfo: ViewFrame?
    let transitionDuration: TimeInterval = DefaultAnimationDuration

    required init(
        categoryViewController: CategoryDetailViewController,
        categoryCell: UIView
    ) {
        if let window = categoryCell.window,
            let categoryViewSnapshot = categoryViewController.view.snapshotView(
                afterScreenUpdates: true
            ),
            let categoryCellSnapshot = categoryCell.snapshotView(afterScreenUpdates: true)
        {
            categoryViewSnapshot.contentMode = .top
            categoryViewSnapshot.clipsToBounds = true
            self.categoryViewInfo = (
                categoryViewSnapshot, window.convertFrame(of: categoryViewController.view)
            )
            self.categoryCellInfo = (categoryCellSnapshot, window.convertFrame(of: categoryCell))
        }
        else {
            self.categoryViewInfo = nil
            self.categoryCellInfo = nil
        }

        super.init()
    }

}

class CategoryPresentAnimation: CategoryAnimation, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?)
        -> TimeInterval
    {
        return self.transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toVC = transitionContext.viewController(forKey: .to)
        else { return }

        let categoryCell = categoryCellInfo?.view
        let categoryCellFrame = categoryCellInfo?.frame
        let categoryView = categoryViewInfo?.view

        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)
        toVC.view.frame = finalFrame
        toVC.view.isHidden = true
        containerView.addSubview(toVC.view)

        if let categoryView = categoryView, let frame = categoryCellFrame {
            containerView.addSubview(categoryView)
            categoryView.frame = frame
        }

        if let categoryCell = categoryCell, let frame = categoryCellFrame {
            containerView.addSubview(categoryCell)
            categoryCell.frame = frame
        }

        animate(duration: transitionDuration) {
            categoryCell?.alpha = 0
            categoryCell?.frame.origin = .zero
            categoryView?.frame = finalFrame
        }.done {
            transitionContext.completeTransition(true)
            categoryView?.isHidden = true
            toVC.view.isHidden = false
        }
    }
}

class CategoryDismissAnimation: CategoryAnimation, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?)
        -> TimeInterval
    {
        return self.transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
        else { return }

        let categoryCell = categoryCellInfo?.view
        let categoryCellFrame = categoryCellInfo?.frame
        let categoryView = categoryViewInfo?.view

        let containerView = transitionContext.containerView
        fromVC.view.isHidden = true

        if let categoryView = categoryView {
            containerView.addSubview(categoryView)
            let finalFrame = transitionContext.finalFrame(for: toVC)
            categoryView.frame = finalFrame
        }

        if let categoryCell = categoryCell, let frame = categoryCellFrame {
            containerView.addSubview(categoryCell)
            categoryCell.frame.origin = .zero
            categoryCell.frame.size = frame.size
        }

        categoryCell?.alpha = 0

        animate(duration: transitionDuration) {
            categoryCell?.alpha = 1

            if let frame = categoryCellFrame {
                categoryCell?.frame.origin = frame.origin
                categoryView?.frame = frame
            }
        }.done {
            transitionContext.completeTransition(true)
        }
    }
}
