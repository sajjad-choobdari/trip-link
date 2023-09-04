//
//  AppSettingsTableVC.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/4/23.

import UIKit

class AppSettingsTableVC: UITableViewController {
	@IBOutlet weak var loadDeviceContactsRow: UITableViewCell!

	let contactsModel = Contacts()

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		guard let identifier = tableView.cellForRow(at: indexPath)?.reuseIdentifier else {
			return
		}

		switch identifier {
			case "LoadDeviceContacts":
				if (hasContactsAccess()) {
					loadDeviceContactsRow.selectionStyle = .none
					contactsModel.loadDeviceContacts {
						self.loadDeviceContactsRow.selectionStyle = .default
						let alert = UIAlertController(title: "Done", message: "", preferredStyle: .alert)
						alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
						self.present(alert, animated: true, completion: nil)
					}
				} else {
					requestContactsAccess()
				}
				break

			case "DeleteAllContacts":
				let alert = UIAlertController(
					title: "",
					message: "Are you sure you want to delete all your contacts? this action can not be undo",
					preferredStyle: .actionSheet
				)
				alert.addAction(UIAlertAction(
					title: "Delete All Contacts",
					style: .destructive,
					handler: { _ in
						self.contactsModel.deleteAllContacts {
							let alert = UIAlertController(title: "Done", message: "", preferredStyle: .alert)
							alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
							self.present(alert, animated: true, completion: nil)
						}
					})
				)
				alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
				self.present(alert, animated: true, completion: nil)

			default:
				break
		}
	}
}

