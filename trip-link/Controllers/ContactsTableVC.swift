//
//  ContactsTableVC.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 8/30/23.
//

import UIKit

let contactCellReuseIdentifier = "ContactCell"
class ContactsTableVC: UIViewController {
	@IBOutlet var tableView: UITableView!

	private let contactsModel = Contacts()

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.register(UITableViewCell.self, forCellReuseIdentifier: contactCellReuseIdentifier)
		tableView.backgroundColor = UIColor.clear
		tableView.dataSource = self
		tableView.delegate = self
	}

}


extension ContactsTableVC: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return contactsModel.getItems().count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: contactCellReuseIdentifier, for: indexPath)
		let contactItem = contactsModel.getItems()[indexPath.row]
		cell.textLabel!.text = contactItem.givenName
		return cell
	}

	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		return .none
	}
}

extension ContactsTableVC: UITableViewDelegate {
	//
}
