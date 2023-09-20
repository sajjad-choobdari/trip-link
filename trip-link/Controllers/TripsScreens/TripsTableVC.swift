//
//  TripsTableVC.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/16/23.
//

import UIKit

class TripsTableVC: UITableViewController {
		// Variables
	private let tripsModel = Trips()
	private let TRIP_CELL_REUSE_IDENTIFIER = "TripCell"

	override func viewDidLoad() {
		super.viewDidLoad()
		let nib = UINib(nibName: String(describing: TripTableViewCell.self), bundle: nil)
		self.tableView.register(nib, forCellReuseIdentifier: TRIP_CELL_REUSE_IDENTIFIER)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
	}
}

extension TripsTableVC {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tripsModel.getItems().count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: TRIP_CELL_REUSE_IDENTIFIER, for: indexPath) as! TripTableViewCell
		let tripItem = tripsModel.getItems()[indexPath.row]
		
		cell.titleLabel.text = tripItem.title
		cell.descriptionLabel.text = tripItem.description
		cell.originAddressLabel.text = tripItem.origin.details
		cell.destinationAddressLabel.text = tripItem.destination.details

		return cell
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		return .none
	}

	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let item = tripsModel.getItems()[indexPath.row]

		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
			self.tripsModel.deleteTripByUUID(id: item.id) {
				tableView.deleteRows(at: [indexPath], with: .automatic)
			}
			completionHandler(true)
		}
		let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
		return configuration
	}

}
