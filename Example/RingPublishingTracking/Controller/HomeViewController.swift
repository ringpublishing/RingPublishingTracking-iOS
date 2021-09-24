//
//  HomeViewController.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 06/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import UIKit

class HomeViewController: UIPageViewController {

    private lazy var pagerViewControllers: [UIViewController] = {
        return preparePagerViewControllers()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self

        guard let initialController = pagerViewControllers.first else { return }

        setViewControllers([initialController], direction: .forward, animated: false, completion: nil)
    }
}

// MARK: Private
private extension HomeViewController {

    func preparePagerViewControllers() -> [UIViewController] {
        let controllerIdentifiers = ["ListViewController", "ActionsViewController", "NonContentViewController"]
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        return controllerIdentifiers.compactMap { storyboard.instantiateViewController(withIdentifier: $0) as? PagerViewController }
            .sorted { return $0.pageIndex < $1.pageIndex }
    }
}

// MARK: UIPageViewControllerDataSource
extension HomeViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let pagerController = viewController as? PagerViewController else { return nil }

        let lowerIndex = pagerController.pageIndex - 1
        return pagerViewControllers.compactMap { $0 as? PagerViewController }.first(where: { $0.pageIndex == lowerIndex })
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let pagerController = viewController as? PagerViewController else { return nil }

        let higherIndex = pagerController.pageIndex + 1
        return pagerViewControllers.compactMap { $0 as? PagerViewController }.first(where: { $0.pageIndex == higherIndex })
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pagerViewControllers.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
