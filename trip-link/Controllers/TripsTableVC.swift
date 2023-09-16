//
//  TripsTableVC.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/16/23.
//

import UIKit

class TripsTableVC: UITableViewController {

	private let tripCellReuseIdentifier = "TripCell"

	// Variables
	private let tripsModel = Trips()

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: tripCellReuseIdentifier)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
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
		let cell = tableView.dequeueReusableCell(withIdentifier: tripCellReuseIdentifier, for: indexPath)
		let tripItem = tripsModel.getItems()[indexPath.row]
		cell.textLabel?.text = tripItem.title
		return cell
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		return .none
	}
}

extension TripsTableVC {
//
}
