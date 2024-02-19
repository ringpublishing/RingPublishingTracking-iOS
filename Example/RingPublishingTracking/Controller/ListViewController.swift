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
        cell.detailTextLabel?.text = "Content paid for: \(articleData.contentWasPaidFor)"

        return cell
    }
}

// MARK: UITableViewDelegate
extension ListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: detailSegueIdentifier, sender: self)

        // Report content click event

        let selectedArticle = sampleArticleData[indexPath.row]
        let aureusOfferId = "a4gb35"
        let teaser = AureusTeaser(teaserId: "teaser_id_1", contentId: selectedArticle.contentId)
        let aureusContext = AureusEventContext(clientUuid: "581ad584-2333-4e69-8963-c105184cfd04",
                                               variantUuid: "0e8c860f-006a-49ef-923c-38b8cfc7ca57",
                                               batchId: "79935e2327",
                                               recommendationId: "e4b25216db",
                                               segmentId: "group1.segment1")

        RingPublishingTracking.shared.reportContentClick(selectedElementName: selectedArticle.title,
                                                         publicationUrl: selectedArticle.publicationUrl,
                                                         aureusOfferId: aureusOfferId,
                                                         teaser: teaser,
                                                         eventContext: aureusContext)
    }
}
