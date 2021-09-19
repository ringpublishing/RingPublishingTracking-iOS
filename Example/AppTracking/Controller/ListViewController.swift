//
//  ListViewController.swift
//  AppTracking-Example
//
//  Created by Adam Szeremeta on 17/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import UIKit
import AppTracking

// swiftlint:disable force_unwrapping

class ListViewController: UIViewController, PagerViewController, TraceableScreen {

    @IBOutlet private weak var tableView: UITableView!

    private let detailSegueIdentifier = "DetailViewControllerSegue"

    private var sampleArticleData = [
        SampleArticle(title: "France cancels Washington reception amid submarine spat",
                      publicationUrl: URL(string: "https://example.com/politics/battle-of-the-capes")!,
                      contentWasPaidFor: false),
        SampleArticle(title: "Australia's decades-long balancing act between the US and China is over",
                      publicationUrl: URL(string: "https://example.com/australia-china-us-aukus-submarine")!,
                      contentWasPaidFor: false),
        SampleArticle(title: "Kids worried about the vaccine? Medical expert answers their questions",
                      publicationUrl: URL(string: "https://example.com/sanjay-gupta-students-kids-ask")!,
                      contentWasPaidFor: true)
    ]

    // MARK: PagerViewController

    var pageIndex: Int {
        return 0
    }

    // MARK: TraceableScreen

    var screenTrackingData: ScreenTrackingData {
        return ScreenTrackingData(structurePath: "List", advertisementArea: "ListAdsArea")
    }

    // MARK: Life cycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Update our tracking properties for this screen

        updateTrackingProperties()

        // Report page view event

        AppTracking.shared.reportPageView(partiallyReloaded: false)
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

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ListAppTrackingDemo")
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
        AppTracking.shared.reportContentClick(selectedElementName: selectedArticle.title,
                                              publicationUrl: selectedArticle.publicationUrl)
    }
}
