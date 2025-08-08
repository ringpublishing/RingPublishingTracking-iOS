//
//  ListViewController.swift
//  RingPublishingTracking-Example
//
//  Created by Adam Szeremeta on 17/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import UIKit
import RingPublishingTracking

class ListViewController: UIViewController, PagerViewController, TraceableScreen {

    @IBOutlet private weak var tableView: UITableView!

    private let detailSegueIdentifier = "DetailViewControllerSegue"

    private var sampleArticleData = SampleArticle.testData

    // MARK: PagerViewController

    var pageIndex: Int {
        return 0
    }

    // MARK: TraceableScreen

    var screenTrackingData: ScreenTrackingData {
        return ScreenTrackingData(structurePath: ["Home", "List"], advertisementArea: "ListAdsArea")
    }

    // MARK: Life cycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Update our tracking properties for this screen

        updateTrackingProperties()

        // Report page view event

        RingPublishingTracking.shared.reportPageView(currentStructurePath: screenTrackingData.structurePath, partiallyReloaded: false)
    }

    // MARK: Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard let selectedIndexPath = tableView.indexPathForSelectedRow,
              let detailController = segue.destination as? DetailViewController else { return }

        let selectedArticle = sampleArticleData[selectedIndexPath.row]
        detailController.article = selectedArticle
    }
}

// MARK: UITableViewDataSource
extension ListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleArticleData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let articleData = sampleArticleData[indexPath.row]

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ListRingPublishingTrackingDemo")
        cell.selectionStyle = .none
        cell.textLabel?.text = articleData.title
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = "Content marked as paid: \(articleData.paidContent)"

        return cell
    }
}

// MARK: UITableViewDelegate
extension ListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: detailSegueIdentifier, sender: self)

        // Report content click event

        let selectedArticle = sampleArticleData[indexPath.row]
        RingPublishingTracking.shared.reportContentClick(selectedElementName: selectedArticle.title,
                                                         publicationUrl: selectedArticle.publicationUrl,
                                                         contentId: selectedArticle.contentId)

        // Report content click event with Aureus context

        let teaser = AureusTeaser(teaserId: "teaserId", offerId: "offerId", contentId: selectedArticle.contentId)
        let context = AureusEventContext(clientUuid: "5f37f85f-a8ad-4e6c-a426-5a42fce67ecc",
                                         variantUuid: "4f37f85f-a8ad-4e6c-a426-5a42fce67ecc",
                                         batchId: "g9fewcisss",
                                         recommendationId: "a5uam4ufuu",
                                         segmentId: "uuid_word2vec_artemis_id_bisect_50_10.8",
                                         impressionEventType: "AUREUS_IMPRESSION_EVENT_AND_USER_ACTION")

        RingPublishingTracking.shared.reportContentClick(selectedElementName: selectedArticle.title,
                                                         publicationUrl: selectedArticle.publicationUrl,
                                                         teaser: teaser,
                                                         eventContext: context)

        // Report content click using new event type for Aureus

        let contextNew = AureusEventContext(clientUuid: "5f37f85f-a8ad-4e6c-a426-5a42fce67ecc",
                                            variantUuid: "4f37f85f-a8ad-4e6c-a426-5a42fce67ecc",
                                            batchId: "g9fewcisss",
                                            recommendationId: "a5uam4ufuu",
                                            segmentId: "uuid_word2vec_artemis_id_bisect_50_10.8",
                                            impressionEventType: "AUREUS_IMPRESSION_EVENT")

        RingPublishingTracking.shared.reportContentClick(selectedElementName: selectedArticle.title,
                                                         publicationUrl: selectedArticle.publicationUrl,
                                                         teaser: teaser,
                                                         eventContext: contextNew)
    }
}
