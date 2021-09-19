//
//  DetailViewController.swift
//  AppTracking-Example
//
//  Created by Adam Szeremeta on 17/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    private var detailContentBlocks = [String]()

    var article: SampleArticle? {
        didSet {
            guard let article = article else { return }

            detailContentBlocks = [article.title] + article.content
        }
    }

    // MARK: Actions

    @IBAction func onAddMoreContentActionTouch(_ sender: Any) {
        guard let article = article else { return }

        detailContentBlocks.append(contentsOf: article.content)
        tableView.reloadData()
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
