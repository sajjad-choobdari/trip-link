//
//  ContactScreenVC.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 8/30/23.
//

import UIKit
//import Foundation

enum ContactViewMode {
	case view
	case edit
	case add
}

protocol ContactScreenDelegate: AnyObject {
	var contactViewMode: ContactViewMode { get set }
}

class ContactScreenVC: UITableViewController {
		// Outlets

		// Variables
	var contactViewMode = ContactViewMode.view
	var cancelButton: UIBarButtonItem!
	var doneButton: UIBarButtonItem!
	var editButton: UIBarButtonItem!

		// Methods
	func updateActionButtons(for mode: ContactViewMode) {
		switch mode {
			case .add:
				navigationItem.leftBarButtonItems = [cancelButton]
				navigationItem.rightBarButtonItems = [doneButton]
				break
			case .view:
				navigationItem.leftBarButtonItems = []
				navigationItem.rightBarButtonItems = [editButton]
				break
			case .edit:
				navigationItem.leftBarButtonItems = [cancelButton]
				navigationItem.rightBarButtonItems = [doneButton]
				break
		}
	}

	func navigateBack() {
		if let navigationController = self.navigationController {
			navigationController.popViewController(animated: true)
		}
	}

	func showDiscardChangesAlert() {
		let alert = UIAlertController(
			title: "",
			message: "Are you sure you want to discard your changes?",
			preferredStyle: .actionSheet
		)

		let discardAction = UIAlertAction(
			title: "Discard Changes",
			style: .destructive,
			handler: { _ in
				self.navigateBack()
			}
		)
		let keepEditingAction = UIAlertAction(
			title: "Keep Editing",
			style: .cancel,
			handler: nil
		)

		alert.addAction(discardAction)
		alert.addAction(keepEditingAction)

		self.present(alert, animated: true, completion: nil)
	}


	// Life Cycles
	override func viewDidLoad() {
		super.viewDidLoad()

		cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(onPressCancel))
		doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(onPressDone))
		editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(onPressEdit))
		updateActionButtons(for: self.contactViewMode)
	}

	// Actions
	@objc func onPressEdit() {
		if (contactViewMode == ContactViewMode.view) {
			contactViewMode = ContactViewMode.edit
			updateActionButtons(for: ContactViewMode.edit)
		}
	}

	@objc func onPressDone() {
		if (contactViewMode == ContactViewMode.edit) {
			// save changes and update model and view and get back to view mode
			self.contactViewMode = ContactViewMode.view
			updateActionButtons(for: ContactViewMode.view)
		} else if (contactViewMode == ContactViewMode.add) {
			// save changes and update model and navigate back
			navigateBack()
		}
	}

	@objc func onPressCancel() {
		if (contactViewMode == ContactViewMode.edit) {
			// get confirmation from user for discarding changes and get back to view mode
			self.contactViewMode = ContactViewMode.view
			updateActionButtons(for: ContactViewMode.view)
		} else if (contactViewMode == ContactViewMode.add) {
			// get confirmation from user for discarding changes and navigate back
			showDiscardChangesAlert()
		}
	}
}
