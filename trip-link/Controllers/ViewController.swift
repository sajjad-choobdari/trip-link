//
//  ViewController.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 8/28/23.
//

import UIKit

class ViewController: UIViewController {
	@IBOutlet var contactsTableContainerView: UIView!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.embedChildVCIntoContainerView(ContactsTableVC.self, into: contactsTableContainerView)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.removeEmbeddedChildViewController(from: contactsTableContainerView)
	}

		// Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "AddNewContactSegue" {
			if let destinationVC = segue.destination as? ContactScreenVC {
				destinationVC.contactViewMode = ContactViewMode.add
			}
		}
	}

}
