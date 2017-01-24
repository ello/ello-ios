//
// Created by Brandon Brisbon on 5/22/15.
// Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

class IntroViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var pageViewController: UIPageViewController?
    var viewControllers: [IntroPageController] = []
    var pageControl: UIPageControl = UIPageControl()

    override func viewDidLoad()
    {
        super.viewDidLoad()

        let storyboard = UIStoryboard(name: "Intro", bundle: nil)

        pageViewController = storyboard.instantiateViewController(withIdentifier: "IntroPager") as? UIPageViewController

        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let frame = CGRect(x: 0, y: 0, width: width, height: height)

        pageViewController?.view.frame = frame
        pageViewController?.dataSource = self
        pageViewController?.delegate = self

        // Load and set views/pages
        let welcomePageViewController = storyboard
            .instantiateViewController(withIdentifier: "WelcomePage") as! WelcomePageController
        welcomePageViewController.pageIndex = 0

        let inspiredPageViewController = storyboard
            .instantiateViewController(withIdentifier: "InspiredPage") as! InspiredPageController
        inspiredPageViewController.pageIndex = 1

        let friendsPageViewController = storyboard
            .instantiateViewController(withIdentifier: "FriendsPage") as! FriendsPageController
        friendsPageViewController.pageIndex = 2

        let lovesPageViewController = storyboard
            .instantiateViewController(withIdentifier: "LovesPage") as! LovesPageController
        lovesPageViewController.pageIndex = 3

        viewControllers = [
            welcomePageViewController,
            inspiredPageViewController,
            friendsPageViewController,
            lovesPageViewController
        ]

        pageViewController!.setViewControllers([welcomePageViewController],
            direction: .forward, animated: false, completion: nil)
        pageViewController!.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)

        // Setup the page control
        pageControl.frame = CGRect(x: 0, y: 20, width: 80, height: 37)
        pageControl.frame.origin.x = view.bounds.size.width / 2 - pageControl.frame.size.width / 2
        pageControl.currentPage = 0
        pageControl.numberOfPages = viewControllers.count
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .greyA()
        pageControl.autoresizingMask = [.flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin]

        // Setup skip button
        let skipButton = UIButton()
        let skipButtonRightMargin: CGFloat = 10
        skipButton.frame = CGRect(x: 0, y: 20, width: 0, height: 0)
        skipButton.setTitle("Skip", for: .normal)
        skipButton.titleLabel?.font = UIFont.defaultFont()
        skipButton.sizeToFit()
        // Set frame margin from right edge
        skipButton.frame.origin.x = view.frame.width - skipButtonRightMargin - skipButton.frame.width
        skipButton.center.y = pageControl.center.y
        skipButton.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin]
        skipButton.setTitleColor(UIColor.greyA(), for: .normal)
        skipButton.addTarget(self, action: #selector(IntroViewController.didTouchSkipIntro(_:)), for: .touchUpInside)

        // Add subviews
        view.addSubview(pageControl)
        view.addSubview(skipButton)

        // Add pager controller
        addChildViewController(pageViewController!)
        view.addSubview(pageViewController!.view)

        // Move everything to the front
        pageViewController!.didMove(toParentViewController: self)
        view.bringSubview(toFront: pageControl)
        view.bringSubview(toFront: skipButton)

        // add status bar to intro
        let bar = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 20))
        bar.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        bar.backgroundColor = UIColor.black
        view.addSubview(bar)
    }

    func didTouchSkipIntro(_ sender: UIButton!) {
        self.dismiss(animated: false, completion:nil)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! IntroPageController).pageIndex!

        if index <= 0 {
            return nil
        }

        index -= 1

        return viewControllerAtIndex(index)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! IntroPageController).pageIndex!

        index += 1

        if index >= viewControllers.count {
            return nil
        }

        return viewControllerAtIndex(index)
    }

    /// Source of truth for if you're on a new page
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        guard
            finished && completed,
            let newCurrentPage = pageViewController.viewControllers?.first as? IntroPageController,
            let pageIndex = newCurrentPage.pageIndex
        else {
            return
        }

        pageControl.currentPage = pageIndex
    }

    func viewControllerAtIndex(_ index: Int) -> UIViewController? {

        if index >= viewControllers.count {
            return nil
        }

        let viewController = viewControllers[index]
        viewController.pageIndex = index

        return viewController
    }
}
