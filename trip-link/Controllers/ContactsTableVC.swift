//
//  ContactsTableVC.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 8/30/23.
//

import UIKit

let contactCellReuseIdentifier = "ContactCell"

class ContactsTableVC: UIViewController {
	// Outlets
	@IBOutlet var tableView: UITableView!

	// Variables
	private let contactsModel = Contacts()

	// Methods
	
	// Life Cycles
	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.register(UITableViewCell.self, forCellReuseIdentifier: contactCellReuseIdentifier)
		tableView.backgroundColor = UIColor.clear
		tableView.dataSource = self
		tableView.delegate = self
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

	// Actions
	func getFullName(contactItem: Contact) -> String {
		var fullName = ""

		if let firstName = contactItem.givenName {
			fullName += firstName
		}
		if let lastName = contactItem.familyName {
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
		cell.textLabel?.text = getFullName(contactItem: contactItem)
		cell.detailTextLabel?.text = contactItem.phoneNumber
		if let imageData = contactItem.image {
			cell.imageView?.image = UIImage(data: imageData)
//			cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.size.height ?? 0) / 2
//			cell.imageView?.clipsToBounds = true
		}
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
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "ShowContactDetailSegue", sender: indexPath)
	}
}
