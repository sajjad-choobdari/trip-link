//
//  ContactsTableVC.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 8/30/23.
//

import UIKit

let contactCellReuseIdentifier = "ContactCell"

class ContactsTableVC: UITableViewController {

	// Variables
	private let contactsModel = Contacts()

	// Methods
	func getFullName(contactItem: Contact) -> String {
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

		tableView.register(ContactsTableViewCell.self, forCellReuseIdentifier: contactCellReuseIdentifier)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
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

extension ContactsTableVC {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return contactsModel.getItems().count
	}


	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: contactCellReuseIdentifier, for: indexPath) as! ContactsTableViewCell
			//	cell = ContactsTableViewCell(style: .subtitle, reuseIdentifier: contactCellReuseIdentifier)
		let contactItem = contactsModel.getItems()[indexPath.row]
		cell.textLabel?.text = getFullName(contactItem: contactItem)
		cell.detailTextLabel?.text = contactItem.mutableProps.phoneNumber
		if let imageView = cell.imageView {
			if let imageData = contactItem.mutableProps.image {
				imageView.image = UIImage(data: imageData)
			} else {
				imageView.image = UIImage(systemName: "person.crop.circle")
			}
		}
		return cell
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}

	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		return .none
	}
}

extension ContactsTableVC {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "ShowContactDetailSegue", sender: indexPath)
	}
}
