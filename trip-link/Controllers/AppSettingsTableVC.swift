//
//  AppSettingsTableVC.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 9/4/23.

import UIKit

protocol CommandHandler {
	func perform(on cell: UITableViewCell)
}

class LoadDeviceContactsHandler: CommandHandler {
	weak var controller: UIViewController?
	let contactsModel = Contacts()

	func perform(on cell: UITableViewCell) {
		guard PermissionsManager.hasContactsAccess() else {
			PermissionsManager.requestContactsAccess()
			return
		}

		cell.selectionStyle = .none
		contactsModel.loadDeviceContacts {
			cell.selectionStyle = .default
			if let controller = self.controller {
				AlertUtility.showAlert(on: controller, title: "Done", primaryActionTitle: "OK")
			}
		}
	}
}

class DeleteAllContactsHandler: CommandHandler {
	weak var controller: UIViewController?
	let contactsModel = Contacts()

	func perform(on cell: UITableViewCell) {
		if let controller = self.controller {
			AlertUtility.showActionSheet(
				on: controller,
				title: "",
				message: "Are you sure you want to delete all your contacts? this action can not be undo",
				confirmActionTitle: "Delete All Contacts",
				confirmActionStyle: .destructive,
				confirmHandler: { _ in
					self.contactsModel.deleteAllContacts {
						AlertUtility.showAlert(on: controller, title: "Done", primaryActionTitle: "OK")
					}
				}
			)
		}
	}
}

class AppSettingsTableVC: UITableViewController {
	@IBOutlet weak var loadDeviceContactsRow: UITableViewCell!

	lazy var cellClickHandlers: [String: CommandHandler] = {
		let loadHandler = LoadDeviceContactsHandler()
		loadHandler.controller = self
		let deleteHandler = DeleteAllContactsHandler()
		deleteHandler.controller = self
		return [
			"LoadDeviceContacts": loadHandler,
			"DeleteAllContacts": deleteHandler
		]
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		guard let cell = tableView.cellForRow(at: indexPath),
					let identifier = cell.reuseIdentifier,
					let handler = cellClickHandlers[identifier]
		else {
			return
		}

		handler.perform(on: cell)
	}
}
