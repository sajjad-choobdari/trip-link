//
//  ContactsScreenVC.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 8/28/23.
//

import UIKit

class ContactsScreenVC: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
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
