//
//  DetailViewController.swift
//  AppTracking-Example
//
//  Created by Adam Szeremeta on 17/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import UIKit
import RingPublishingTracking

class DetailViewController: UIViewController, TraceableScreen {

    @IBOutlet private weak var tableView: UITableView!

    private var detailContentBlocks = [String]()

    var article: SampleArticle? {
        didSet {
            guard let article = article else { return }

            detailContentBlocks = [article.title] + article.content
        }
    }

    var contentViewSource: ContentPageViewSource = .default

    // MARK: TraceableScreen

    var screenTrackingData: ScreenTrackingData {
        return ScreenTrackingData(structurePath: ["Home", "Detail"], advertisementArea: "DetailAdsArea")
    }

    // MARK: Life cycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Update our tracking properties for this screen

        updateTrackingProperties()

        // Report content page view event and start keep alive tracking

        reportContentPageView(partiallyReloaded: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let isClosing = isBeingDismissed || isMovingFromParent

        // If our controller with content will not longer be presented we have to stop keep alive tracking

        if isClosing {
            RingPublishingTracking.shared.stopContentKeepAliveTracking()
            return
        }

        // If our content controller will be obscured (not by content view) we should pause keep alive tracking and then resume it
        // when view which covered our content will be dismissed
        // To resume tracking we can call either again 'reportContentPageView' method or 'resumeContentKeepAliveTracking'

        RingPublishingTracking.shared.pauseContentKeepAliveTracking()
    }

    // MARK: Actions

    @IBAction func onAddMoreContentActionTouch(_ sender: Any) {
        guard let article = article else { return }

        detailContentBlocks.append(contentsOf: article.content)
        tableView.reloadData()

        // Report page view event when screen was partially reloaded
        // Keep alive tracking for the same content will not be interrupted

        reportContentPageView(partiallyReloaded: true)
    }

    @IBAction func onPushActionTouch(_ sender: Any) {
        // Show empty view controller to pause detail content tracking
        // For demo purpose we are pushing here empty controller but this should be handled by the app in all cases:
        // - pushing view controllers
        // - presenting modally view controllers
        // - presenting views which obscure content

        let viewController = UIViewController()
        viewController.view.backgroundColor = .systemGray

        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func onShowModalActionTouch(_ sender: Any) {
        // Show empty view controller to pause detail content tracking
        // For demo purpose we are presenting here empty controller but this should be handled by the app in all cases:
        // - pushing view controllers
        // - presenting modally view controllers
        // - presenting views which obscure content

        let viewController = UIViewController()
        viewController.view.backgroundColor = .systemGray
        viewController.presentationController?.delegate = self

        present(viewController, animated: true, completion: nil)
    }
}

// MARK: UIAdaptivePresentationControllerDelegate
extension DetailViewController: UIAdaptivePresentationControllerDelegate {

    func presentationController(_ presentationController: UIPresentationController,
                                willPresentWithAdaptiveStyle style: UIModalPresentationStyle,
                                transitionCoordinator: UIViewControllerTransitionCoordinator?) {
        // Pause keep alive tracking when modal controller is presented

        RingPublishingTracking.shared.pauseContentKeepAliveTracking()
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        // Resume keep alive tracking when modal controller is dismissed

        RingPublishingTracking.shared.resumeContentKeepAliveTracking()
    }
}

// MARK: UITableViewDataSource
extension DetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailContentBlocks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let paragraph = detailContentBlocks[indexPath.row]

        let cell = UITableViewCell(style: .default, reuseIdentifier: "DetailAppTrackingDemo")
        cell.selectionStyle = .none
        cell.textLabel?.text = paragraph
        cell.textLabel?.numberOfLines = 0

        return cell
    }
}

// MARK: Private
private extension DetailViewController {

    func reportContentPageView(partiallyReloaded: Bool) {
        guard let article = article else { return }

        let contentMetadata = ContentMetadata(publicationId: article.publicationId,
                                              publicationUrl: article.publicationUrl,
                                              sourceSystemName: article.sourceSystemName,
                                              contentWasPaidFor: article.contentWasPaidFor)

        RingPublishingTracking.shared.reportContentPageView(contentMetadata: contentMetadata,
                                                 pageViewSource: contentViewSource,
                                                 currentStructurePath: screenTrackingData.structurePath,
                                                 partiallyReloaded: partiallyReloaded,
                                                 contentKeepAliveDataSource: self)
    }
}

// MARK: AppTrackingKeepAliveDataSource
extension DetailViewController: RingPublishingTrackingKeepAliveDataSource {

    func appTracking(_ appTracking: RingPublishingTracking,
                     didAskForKeepAliveContentStatus content: ContentMetadata) -> KeepAliveContentStatus {
        // Return information about content at given point in time
        // We have to return how big content is and how far the user has scrolled

        return KeepAliveContentStatus(scrollOffset: tableView.contentOffset.y, contentSize: tableView.contentSize)
    }
}
