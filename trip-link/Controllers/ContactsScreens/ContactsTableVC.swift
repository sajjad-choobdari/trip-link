//
//  ContactsTableVC.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 8/30/23.
//

import UIKit

class ContactsTableVC: UITableViewController {

	// Variables
	private let contactsModel = Contacts()
	private let CONTACT_CELL_REUSE_IDENTIFIER = "ContactCell"

	// Methods
	private func getFullName(contactItem: Contact) -> String {
		var fullName = ""

		if let firstName = contactItem.mutableProps.givenName {
			fullName += firstName
		}
		if let lastName = contactItem.mutableProps.familyName {
			if !fullName.isEmpty {
				fullName += " "
			}
			fullName += lastName
		}
		if fullName.isEmpty {
			fullName += "No Name"
		}

		return fullName
	}

	// Life Cycles
	override func viewDidLoad() {
		super.viewDidLoad()
		let nib = UINib(nibName: String(describing: ContactTableViewCell.self), bundle: nil)
		self.tableView.register(nib, forCellReuseIdentifier: CONTACT_CELL_REUSE_IDENTIFIER)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
	}

	// Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ShowContactDetailSegue" {
			if let indexPath = sender as? IndexPath {
				let selectedContact = contactsModel.getItems()[indexPath.row]

				if let destinationVC = segue.destination as? ContactScreenVC {
					destinationVC.contactViewMode = ContactViewMode.view
					destinationVC.contact = selectedContact
				}
			}
		}
	}

}

// data source methods
extension ContactsTableVC {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return contactsModel.getItems().count
	}


	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: CONTACT_CELL_REUSE_IDENTIFIER, for: indexPath) as! ContactTableViewCell
		let contactItem = contactsModel.getItems()[indexPath.row]

		cell.contactTitleLabel.text = getFullName(contactItem: contactItem)
		cell.contactSubtitleLabel.text = contactItem.mutableProps.phoneNumber
		if let imageData = contactItem.mutableProps.image {
			cell.contactImageView.image = UIImage(data: imageData)
		}

		return cell
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		return .none
	}

	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let item = contactsModel.getItems()[indexPath.row]

		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
			self.contactsModel.deleteContactByUUID(id: item.immutableProps.id) {
				tableView.deleteRows(at: [indexPath], with: .automatic)
			}
			completionHandler(true)
		}
		let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
		return configuration
	}
}

// delegate methods
extension ContactsTableVC {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.performSegue(withIdentifier: "ShowContactDetailSegue", sender: indexPath)
	}
}
